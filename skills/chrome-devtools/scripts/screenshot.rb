#!/usr/bin/env ruby
require_relative 'cdp_client'

output_path = ARGV[0] || '/tmp/cdp_screenshot.png'
client = CDPClient.new

# Navigate to a test page
client.navigate('https://example.com')
sleep 1 # Wait for page to load

# Take screenshot
result = client.screenshot(path: output_path, full_page: true)
puts "Screenshot saved to: #{result[:path]}"

client.close
