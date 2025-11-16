#!/usr/bin/env ruby
require_relative 'cdp_client'

url = ARGV[0] || abort("Usage: console_log.rb <url> <duration_seconds>")
duration = (ARGV[1] || 10).to_i

client = CDPClient.new
client.runtime_enable
client.page_enable

logs = []
client.on_event('Runtime.consoleAPICalled') do |params|
  logs << {
    type: params['type'],
    args: params['args'],
    timestamp: Time.now.to_f
  }
end

client.page_navigate(url)
puts "Monitoring console for #{duration} seconds..."
sleep duration

puts "\n=== Console Logs (#{logs.size} total) ==="
logs.each_with_index do |log, i|
  puts "#{i + 1}. [#{log[:type]}] #{log[:args].inspect}"
end

client.close
