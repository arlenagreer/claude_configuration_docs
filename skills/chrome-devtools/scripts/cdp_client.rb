#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'base64'
require 'logger'

class CDPClient
  attr_reader :logger

  DEFAULT_TIMEOUT = 30000
  MAX_RETRIES = 3
  RETRY_DELAY = 1

  def initialize(host: 'localhost', port: 9222, logger: nil)
    @host = host
    @port = port
    @base_url = "http://#{@host}:#{@port}"
    @logger = logger || Logger.new(STDOUT)
    @logger.level = Logger::INFO

    # Verify server is reachable
    verify_connection
  end

  def verify_connection
    retries = 0
    begin
      response = http_get('/health')
      @logger.info("Connected to CDP API Server: #{response}")
    rescue => e
      if retries < MAX_RETRIES
        retries += 1
        @logger.warn("Connection failed, retrying (#{retries}/#{MAX_RETRIES})...")
        sleep RETRY_DELAY
        retry
      end
      raise ConnectionError, "Failed to connect to CDP API Server at #{@base_url}: #{e.message}"
    end
  end

  def navigate(url, wait_until: 'load', timeout: DEFAULT_TIMEOUT)
    http_post('/navigate', {
      url: url,
      waitUntil: wait_until,
      timeout: timeout
    })
  end

  def screenshot(path: nil, full_page: false, type: 'png', quality: nil)
    params = {
      fullPage: full_page,
      type: type
    }
    params[:quality] = quality if type == 'jpeg' && quality

    result = http_post('/screenshot', params)

    if path
      # Decode base64 and save to file
      File.binwrite(path, Base64.decode64(result['buffer']))
      { success: true, path: path }
    else
      result
    end
  end

  def click(selector, timeout: DEFAULT_TIMEOUT)
    http_post('/click', {
      selector: selector,
      timeout: timeout
    })
  end

  def fill(selector, value, timeout: DEFAULT_TIMEOUT)
    http_post('/fill', {
      selector: selector,
      value: value,
      timeout: timeout
    })
  end

  def evaluate(expression)
    result = http_post('/evaluate', {
      expression: expression
    })
    result['result']
  end

  def wait_for_selector(selector, timeout: DEFAULT_TIMEOUT)
    http_post('/wait', {
      selector: selector,
      timeout: timeout
    })
  end

  def content
    result = http_get('/content')
    result['content']
  end

  def title
    result = http_get('/title')
    result['title']
  end

  def console_logs
    result = http_get('/console')
    result['logs']
  end

  def network_requests
    result = http_get('/network')
    result['requests']
  end

  def close
    begin
      http_post('/close', {})
    rescue => e
      @logger.warn("Error closing browser: #{e.message}")
    end
  end

  private

  def http_get(path)
    uri = URI("#{@base_url}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 60

    request = Net::HTTP::Get.new(uri.path)
    request['Content-Type'] = 'application/json'

    response = http.request(request)
    handle_response(response)
  end

  def http_post(path, body)
    uri = URI("#{@base_url}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 60

    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request.body = body.to_json

    response = http.request(request)
    handle_response(response)
  end

  def handle_response(response)
    case response.code.to_i
    when 200..299
      JSON.parse(response.body)
    when 400..499
      error_data = JSON.parse(response.body) rescue {}
      raise CommandError, error_data['error'] || "Client error: #{response.code}"
    when 500..599
      error_data = JSON.parse(response.body) rescue {}
      raise CommandError, error_data['error'] || "Server error: #{response.code}"
    else
      raise CommandError, "Unexpected response: #{response.code}"
    end
  rescue JSON::ParserError
    raise CommandError, "Invalid JSON response: #{response.body}"
  end

  class ConnectionError < StandardError; end
  class CommandError < StandardError; end
  class TimeoutError < StandardError; end
end

# Example usage (for testing)
if __FILE__ == $0
  client = CDPClient.new

  puts "Navigating to example.com..."
  result = client.navigate('https://example.com')
  puts "Navigation result: #{result}"

  puts "Taking screenshot..."
  client.screenshot(path: '/tmp/example.png', full_page: true)
  puts "Screenshot saved to /tmp/example.png"

  puts "Evaluating JavaScript..."
  title = client.evaluate('document.title')
  puts "Page title: #{title}"

  client.close
end
