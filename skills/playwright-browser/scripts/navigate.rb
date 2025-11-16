#!/usr/bin/env ruby
# ~/.claude/skills/playwright-browser/scripts/navigate.rb
require_relative 'playwright_client'

url = ARGV[0] || abort("Usage: navigate.rb <url>")
client = PlaywrightClient.new
result = client.navigate(url)
puts JSON.pretty_generate(result)
client.close
