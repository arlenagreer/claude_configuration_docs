#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'slack-ruby-client'
require 'optparse'

# Parse command line options
@options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: slack_manager.rb OPERATION [--workspace WORKSPACE_ID]"

  opts.on("--workspace WORKSPACE_ID", "Workspace ID (dreamanager, american_laboratory_trading, softtrak)") do |workspace|
    @options[:workspace] = workspace
  end
end.parse!

# Auto-detect workspace from current working directory
def detect_workspace_from_pwd
  mappings_path = File.expand_path('~/.claude/.slack/workspace_mappings.json')
  return nil unless File.exist?(mappings_path)

  begin
    mappings = JSON.parse(File.read(mappings_path))
    pwd = Dir.pwd

    mappings['project_mappings'].each do |mapping|
      mapping['project_paths'].each do |project_path|
        return mapping['workspace_id'] if pwd.start_with?(project_path)
      end
    end

    nil
  rescue StandardError => e
    # Silent fallback if auto-detection fails
    nil
  end
end

# Load workspace configuration
def load_workspace_config(workspace_id)
  workspaces_dir = File.expand_path('~/.claude/.slack/workspaces')
  config_path = File.join(workspaces_dir, "#{workspace_id}.json")

  unless File.exist?(config_path)
    puts JSON.generate({
      status: 'error',
      error: 'workspace_not_found',
      message: "Workspace '#{workspace_id}' not configured",
      config_path: config_path,
      available_workspaces: Dir.glob(File.join(workspaces_dir, '*.json')).map { |f| File.basename(f, '.json') }
    })
    exit 1
  end

  begin
    JSON.parse(File.read(config_path))
  rescue StandardError => e
    puts JSON.generate({
      status: 'error',
      error: 'config_load_failed',
      message: "Failed to load workspace config: #{e.message}",
      config_path: config_path
    })
    exit 1
  end
end

# Exponential backoff retry logic
def retry_with_exponential_backoff(workspace_id, max_retries: 5, initial_delay: 1, factor: 2, max_delay: 60)
  retries = 0

  begin
    yield
  rescue Slack::Web::Api::Errors::TooManyRequestsError => e
    if retries >= max_retries
      puts JSON.generate({
        status: 'error',
        workspace: workspace_id,
        error: 'rate_limited',
        message: 'Rate limit exceeded after max retries',
        retry_after: e.response.headers['retry-after'],
        retries: retries
      })
      exit 1
    end

    retry_after = e.response.headers['retry-after'].to_i
    delay = [retry_after, [initial_delay * (factor**retries), max_delay].min].max

    sleep(delay)
    retries += 1
    retry
  rescue Slack::Web::Api::Errors::ChannelNotFound => e
    puts JSON.generate({
      status: 'error',
      workspace: workspace_id,
      error: 'channel_not_found',
      message: 'Channel not found in workspace',
      suggestion: 'Use list-channels to see available channels'
    })
    exit 1
  rescue Slack::Web::Api::Errors::NotInChannel => e
    puts JSON.generate({
      status: 'error',
      workspace: workspace_id,
      error: 'not_in_channel',
      message: 'Bot is not in channel. Invite bot with: /invite @BotName',
      suggestion: 'Bot must be invited to private channels'
    })
    exit 1
  rescue Slack::Web::Api::Errors::InvalidAuth => e
    puts JSON.generate({
      status: 'error',
      workspace: workspace_id,
      error: 'invalid_auth',
      message: 'Invalid or expired token for workspace',
      suggestion: "Check token in ~/.claude/.slack/workspaces/#{workspace_id}.json"
    })
    exit 1
  rescue Slack::Web::Api::Errors::SlackError => e
    puts JSON.generate({
      status: 'error',
      workspace: workspace_id,
      error: e.class.name.split('::').last.downcase,
      message: e.message
    })
    exit 1
  end
end

# Auto-detect workspace if not explicitly provided
workspace_id = @options[:workspace] || detect_workspace_from_pwd

unless workspace_id
  puts JSON.generate({
    status: 'error',
    error: 'missing_workspace',
    message: 'Could not detect workspace. Please specify --workspace parameter or run from a project directory',
    usage: 'slack_manager.rb OPERATION --workspace WORKSPACE_ID',
    available_workspaces: ['dreamanager', 'american_laboratory_trading', 'softtrak'],
    current_directory: Dir.pwd
  })
  exit 1
end
workspace_config = load_workspace_config(workspace_id)

# Configure Slack client
Slack.configure do |config|
  config.token = workspace_config['access_token']
end

client = Slack::Web::Client.new

# Parse operation and input
operation = ARGV[0]

begin
  input = JSON.parse($stdin.read)
rescue JSON::ParserError => e
  puts JSON.generate({
    status: 'error',
    workspace: workspace_id,
    error: 'invalid_json',
    message: "Invalid JSON input: #{e.message}"
  })
  exit 1
end

case operation
when 'send'
  # Send message to channel or DM
  unless input['channel'] && input['text']
    puts JSON.generate({
      status: 'error',
      workspace: workspace_id,
      error: 'missing_parameters',
      message: 'Missing required parameters: channel, text',
      received: input.keys
    })
    exit 1
  end

  retry_with_exponential_backoff(workspace_id) do
    result = client.chat_postMessage(
      channel: input['channel'],
      text: input['text'],
      as_user: true
    )

    puts JSON.generate({
      status: 'success',
      workspace: workspace_id,
      operation: 'send',
      message_ts: result.ts,
      channel: result.channel
    })
  end

when 'list-channels'
  # List all channels
  retry_with_exponential_backoff(workspace_id) do
    channels = client.conversations_list(
      types: 'public_channel',
      exclude_archived: true
    )

    puts JSON.generate({
      status: 'success',
      workspace: workspace_id,
      operation: 'list-channels',
      channels: channels.channels.map { |c| { id: c.id, name: c.name } }
    })
  end

when 'get-channel-info'
  # Get info about specific channel
  unless input['channel']
    puts JSON.generate({
      status: 'error',
      workspace: workspace_id,
      error: 'missing_parameters',
      message: 'Missing required parameter: channel'
    })
    exit 1
  end

  retry_with_exponential_backoff(workspace_id) do
    info = client.conversations_info(channel: input['channel'])

    puts JSON.generate({
      status: 'success',
      workspace: workspace_id,
      operation: 'get-channel-info',
      channel: {
        id: info.channel.id,
        name: info.channel.name,
        is_private: info.channel.is_private,
        num_members: info.channel.num_members
      }
    })
  end

else
  puts JSON.generate({
    status: 'error',
    workspace: workspace_id,
    error: 'unknown_operation',
    message: "Unknown operation: #{operation}",
    valid_operations: ['send', 'list-channels', 'get-channel-info']
  })
  exit 1
end
