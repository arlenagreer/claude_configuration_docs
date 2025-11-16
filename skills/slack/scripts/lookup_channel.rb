#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'slack-ruby-client'
require 'optparse'

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

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: lookup_channel.rb --name CHANNEL_NAME [--workspace WORKSPACE_ID]"

  opts.on("--name NAME", "Channel name to lookup") do |name|
    options[:name] = name
  end

  opts.on("--workspace WORKSPACE_ID", "Workspace ID (dreamanager, american_laboratory_trading, softtrak)") do |workspace|
    options[:workspace] = workspace
  end
end.parse!

# Validate required parameters
unless options[:name]
  puts JSON.generate({
    status: 'error',
    error: 'missing_name',
    message: 'Missing required --name parameter',
    usage: 'lookup_channel.rb --name CHANNEL_NAME [--workspace WORKSPACE_ID]'
  })
  exit 1
end

# Auto-detect workspace if not explicitly provided
workspace_id = options[:workspace] || detect_workspace_from_pwd

unless workspace_id
  puts JSON.generate({
    status: 'error',
    error: 'missing_workspace',
    message: 'Could not detect workspace. Please specify --workspace parameter or run from a project directory',
    usage: 'lookup_channel.rb --name CHANNEL_NAME --workspace WORKSPACE_ID',
    available_workspaces: ['dreamanager', 'american_laboratory_trading', 'softtrak'],
    current_directory: Dir.pwd
  })
  exit 1
end

# Load workspace configuration
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
  workspace_config = JSON.parse(File.read(config_path))
rescue StandardError => e
  puts JSON.generate({
    status: 'error',
    workspace: workspace_id,
    error: 'config_load_failed',
    message: "Failed to load workspace config: #{e.message}"
  })
  exit 1
end

# Configure Slack client
Slack.configure do |cfg|
  cfg.token = workspace_config['access_token']
end

client = Slack::Web::Client.new

# Normalize channel name (remove # if present)
search_name = options[:name].sub(/^#/, '').downcase

begin
  # Fetch all channels
  channels = client.conversations_list(
    types: 'public_channel,private_channel',
    exclude_archived: true
  )

  # Try exact match first
  exact_match = channels.channels.find { |c| c.name.downcase == search_name }

  if exact_match
    puts JSON.generate({
      status: 'success',
      workspace: workspace_id,
      channel_id: exact_match.id,
      channel_name: exact_match.name,
      match_type: 'exact'
    })
    exit 0
  end

  # Try fuzzy match (contains search term)
  fuzzy_matches = channels.channels.select { |c| c.name.downcase.include?(search_name) }

  if fuzzy_matches.length == 1
    puts JSON.generate({
      status: 'success',
      workspace: workspace_id,
      channel_id: fuzzy_matches.first.id,
      channel_name: fuzzy_matches.first.name,
      match_type: 'fuzzy'
    })
    exit 0
  elsif fuzzy_matches.length > 1
    puts JSON.generate({
      status: 'error',
      workspace: workspace_id,
      error: 'multiple_matches',
      message: 'Multiple channels match. Please be more specific.',
      matches: fuzzy_matches.map { |c| { id: c.id, name: c.name } }
    })
    exit 1
  else
    puts JSON.generate({
      status: 'error',
      workspace: workspace_id,
      error: 'channel_not_found',
      message: "Channel not found: #{options[:name]}",
      suggestion: "List all channels with: echo '{}' | slack_manager.rb list-channels --workspace #{workspace_id}"
    })
    exit 1
  end

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
