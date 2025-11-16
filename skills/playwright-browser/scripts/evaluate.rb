#!/usr/bin/env ruby
require_relative 'playwright_client'

expression = ARGV[0] || abort("Usage: evaluate.rb <javascript_expression>")
client = PlaywrightClient.new
result = client.evaluate(expression)
puts JSON.pretty_generate(result)
client.close
