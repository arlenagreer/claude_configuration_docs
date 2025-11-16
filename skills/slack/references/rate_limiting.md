# Rate Limiting Strategies for Slack API

## Overview

Slack enforces rate limits on API methods to ensure fair usage across all apps. As of May 2025, rate limits have been tightened for non-Marketplace apps. This skill implements exponential backoff with automatic retry to handle rate limits gracefully.

## Rate Limit Tiers

### Tier 1: Strict Limits (1+ request/minute)
- `conversations.history`
- `conversations.replies`
- Maximum 15 objects per request

**Strategy**: Cache results aggressively, minimize calls, use Events API for real-time updates

### Tier 2: Standard Limits (20+ requests/minute)
- Most messaging, channel, and user methods
- Includes `chat.postMessage`, `conversations.list`, `users.list`

**Strategy**: Reasonable caching, batch operations when possible

### Tier 3: Moderate Limits (50+ requests/minute)
- `users.lookupByEmail`
- `team.info`

**Strategy**: Standard retry logic, minimal caching needed

### Tier 4: Generous Limits (100+ requests/minute)
- `auth.test`
- Health check endpoints

**Strategy**: No special handling required

## Multi-Workspace Considerations

**Important**: Rate limits apply **per workspace**, not globally across all workspaces.

- **Dreamanager workspace**: Independent rate limit tracking
- **American Laboratory Trading workspace**: Independent rate limit tracking
- **SoftTrak workspace**: Independent rate limit tracking

**Example**: You can send 20 messages/minute to dreamanager AND 20 messages/minute to softtrak simultaneously without hitting rate limits (assuming Tier 2 limits).

## Exponential Backoff Implementation

### Algorithm
```ruby
def retry_with_exponential_backoff(workspace_id, max_retries: 5, initial_delay: 1, factor: 2, max_delay: 60)
  retries = 0

  begin
    yield
  rescue Slack::Web::Api::Errors::TooManyRequestsError => e
    if retries >= max_retries
      raise e  # Give up after max retries
    end

    # Respect Retry-After header if provided
    retry_after = e.response.headers['retry-after'].to_i

    # Calculate exponential delay: initial * (factor ^ retries)
    exponential_delay = initial_delay * (factor ** retries)

    # Use max of retry_after or exponential_delay, capped at max_delay
    delay = [retry_after, [exponential_delay, max_delay].min].max

    sleep(delay)
    retries += 1
    retry
  end
end
```

### Parameters
- **max_retries**: Maximum retry attempts (default: 5)
- **initial_delay**: Starting delay in seconds (default: 1)
- **factor**: Multiplier for each retry (default: 2)
- **max_delay**: Maximum delay cap (default: 60 seconds)

### Example Delays
| Retry | Delay (seconds) |
|-------|-----------------|
| 0     | 1               |
| 1     | 2               |
| 2     | 4               |
| 3     | 8               |
| 4     | 16              |
| 5     | 32              |

## Caching Strategies

### Channel ID Cache
```ruby
@channel_cache = {}

def get_channel_id(name, workspace_id)
  cache_key = "#{workspace_id}:#{name}"
  return @channel_cache[cache_key] if @channel_cache.key?(cache_key)

  # Fetch from API
  result = client.conversations_list
  result.channels.each do |channel|
    @channel_cache["#{workspace_id}:#{channel.name}"] = channel.id
  end

  @channel_cache[cache_key]
end
```

**Cache Duration**: 1 hour (channels rarely change)
**Workspace Isolation**: Cache keys include workspace ID

### User ID Cache
```ruby
@user_cache = {}

def get_user_id(name, workspace_id)
  cache_key = "#{workspace_id}:#{name}"
  return @user_cache[cache_key] if @user_cache.key?(cache_key)

  # Fetch from API
  result = client.users_list
  result.members.each do |user|
    @user_cache["#{workspace_id}:#{user.real_name}"] = user.id
  end

  @user_cache[cache_key]
end
```

**Cache Duration**: 4 hours (user list changes infrequently)
**Workspace Isolation**: Cache keys include workspace ID

## Batch Operations

### Batch Message Sending
Instead of:
```ruby
# BAD: 100 API calls with no rate limit consideration
messages.each do |msg|
  client.chat_postMessage(channel: msg[:channel], text: msg[:text])
end
```

Use:
```ruby
# GOOD: Queue and send with delays
messages.each_with_index do |msg, index|
  sleep(3) if index % 20 == 0  # Pause every 20 messages (Tier 2 limit)
  retry_with_exponential_backoff(workspace_id) do
    client.chat_postMessage(channel: msg[:channel], text: msg[:text])
  end
end
```

### Multi-Workspace Batch Operations
```ruby
# GOOD: Parallel processing across workspaces (rate limits are per workspace)
workspaces = ['dreamanager', 'american_laboratory_trading', 'softtrak']
threads = workspaces.map do |workspace_id|
  Thread.new do
    messages_for_workspace[workspace_id].each_with_index do |msg, index|
      sleep(3) if index % 20 == 0
      retry_with_exponential_backoff(workspace_id) do
        client.chat_postMessage(channel: msg[:channel], text: msg[:text])
      end
    end
  end
end
threads.each(&:join)
```

## Smart Polling

### Avoid Frequent History Calls
```ruby
# BAD: Frequent history polling (Tier 1 limit: 1 req/min)
loop do
  messages = client.conversations_history(channel: 'C1234567890')
  process(messages)
  sleep(10)  # Still hits rate limit
end
```

### Better: Use Events API
Subscribe to Events API for real-time message events instead of polling `conversations.history`

**Note**: Events API requires webhook endpoint - not implemented in this skill (CLI-focused)

## Monitoring API Usage

### Track Requests Per Workspace
```ruby
class RateLimitMonitor
  def initialize
    @requests = Hash.new { |h, k| h[k] = Hash.new(0) }
    @start_time = Time.now
  end

  def record_request(workspace_id, method)
    @requests[workspace_id][method] += 1
  end

  def report
    elapsed = Time.now - @start_time
    @requests.each do |workspace_id, methods|
      puts "\nWorkspace: #{workspace_id}"
      methods.each do |method, count|
        rate = (count / elapsed) * 60  # requests per minute
        puts "  #{method}: #{count} requests, #{rate.round(2)} req/min"
      end
    end
  end
end
```

## Error Handling

### 429 Response
```http
HTTP/1.1 429 Too Many Requests
Retry-After: 30
```

**Action**: Respect `Retry-After` header, implement exponential backoff

**Implementation**: All scripts automatically handle 429 errors with exponential backoff

### Multi-Workspace Error Handling
```json
{
  "status": "error",
  "workspace": "dreamanager",
  "error": "rate_limited",
  "message": "Rate limit exceeded after max retries",
  "retry_after": 30,
  "retries": 5
}
```

**Key**: Workspace ID included in error response for debugging

## Best Practices

1. **Always Specify Workspace**: Never omit `--workspace` parameter
2. **Check Retry-After Header**: Respect Slack's recommended retry timing
3. **Implement Exponential Backoff with Jitter**: Prevent thundering herd
4. **Cache API Responses**: Especially for channel/user lists (per workspace)
5. **Use Batch Operations**: Add delays for bulk actions
6. **Monitor API Usage**: Track requests per workspace
7. **Use Events API**: For real-time data instead of polling (when feasible)
8. **Workspace Isolation**: Remember rate limits are per workspace

## Rate Limit Recovery

### Automatic Retry Logic
All scripts implement automatic retry with exponential backoff:
- **Max retries**: 5 attempts
- **Initial delay**: 1 second
- **Backoff factor**: 2x per retry
- **Max delay cap**: 60 seconds
- **Retry-After respect**: Uses Slack's header when provided

### Manual Intervention
If scripts report `rate_limited` error after max retries:
1. **Wait**: Respect the `retry_after` value in error response
2. **Reduce Load**: Decrease request frequency
3. **Check Tier**: Verify you're using appropriate API methods for your needs
4. **Consider Events API**: For high-frequency operations

## References
- [Slack Rate Limits Documentation](https://api.slack.com/docs/rate-limits)
- [Rate Limit Changes (May 2025)](https://docs.slack.dev/changelog/2025/05/29/rate-limit-changes-for-non-marketplace-apps/)
- [Exponential Backoff Best Practices](https://cloud.google.com/iot/docs/how-tos/exponential-backoff)
