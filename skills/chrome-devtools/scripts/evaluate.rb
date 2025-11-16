#!/usr/bin/env ruby
require_relative 'cdp_client'
require 'json'

expression = ARGV[0] || abort("Usage: evaluate.rb <javascript_expression>")
client = CDPClient.new

# Navigate to example.com first
client.navigate('https://example.com')
sleep 1 # Wait for page to load

# Evaluate JavaScript
result = client.evaluate(expression)
puts "Result: #{result}"

client.close
