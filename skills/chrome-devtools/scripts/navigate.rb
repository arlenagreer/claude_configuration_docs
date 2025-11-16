#!/usr/bin/env ruby
require_relative 'cdp_client'
require 'json'

url = ARGV[0] || abort("Usage: navigate.rb <url>")
client = CDPClient.new
result = client.navigate(url)
puts JSON.pretty_generate(result)
client.close
