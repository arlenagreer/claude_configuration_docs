#!/usr/bin/env ruby
require_relative 'playwright_client'

url = ARGV[0] || abort("Usage: screenshot.rb <url> <output_path> [--full-page]")
output_path = ARGV[1] || abort("Usage: screenshot.rb <url> <output_path> [--full-page]")
full_page = ARGV.include?('--full-page')

client = PlaywrightClient.new
client.navigate(url)
sleep 2 # Wait for page to settle
result = client.screenshot(path: output_path, full_page: full_page)
puts "Screenshot saved to: #{output_path}"
client.close
