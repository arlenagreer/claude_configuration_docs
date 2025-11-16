#!/usr/bin/env ruby
require_relative 'cdp_client'

url = ARGV[0] || abort("Usage: network_capture.rb <url> <duration_seconds>")
duration = (ARGV[1] || 5).to_i

client = CDPClient.new
client.network_enable
client.page_enable

requests = []
client.on_event('Network.requestWillBeSent') do |params|
  requests << {
    url: params['request']['url'],
    method: params['request']['method'],
    timestamp: Time.now.to_f
  }
end

client.page_navigate(url)
puts "Capturing network traffic for #{duration} seconds..."
sleep duration

puts "\n=== Network Requests (#{requests.size} total) ==="
requests.each_with_index do |req, i|
  puts "#{i + 1}. [#{req[:method]}] #{req[:url]}"
end

client.close
