#!/usr/bin/env ruby
# frozen_string_literal: true

# Google Calendar Manager Script
#
# Purpose: Manage Google Calendar events with full CRUD operations
# Usage: See --help for detailed command examples
# Output: JSON with results or error information
# Exit codes: 0=success, 1=operation failed, 2=auth error, 3=api error, 4=invalid args

require 'optparse'
require 'json'
require 'fileutils'
require 'time'
require 'google/apis/calendar_v3'
require 'google/apis/people_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

# Script version
VERSION = '1.0.0'

# Configuration constants
CALENDAR_SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
CONTACTS_SCOPE = Google::Apis::PeopleV1::AUTH_CONTACTS
CREDENTIALS_PATH = File.join(Dir.home, '.claude', '.google', 'client_secret.json')
TOKEN_PATH = File.join(Dir.home, '.claude', '.google', 'token.json')
OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

# Authorize with Google OAuth 2.0 (Calendar + Contacts scope)
def authorize
  # Check if credentials file exists
  unless File.exist?(CREDENTIALS_PATH)
    return {
      status: 'error',
      code: 'AUTH_ERROR',
      message: "Credentials file not found at #{CREDENTIALS_PATH}"
    }
  end

  # Load client secrets
  begin
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  rescue => e
    return {
      status: 'error',
      code: 'AUTH_ERROR',
      message: "Failed to load credentials: #{e.message}"
    }
  end

  # Create token store with both scopes
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id,
    [CALENDAR_SCOPE, CONTACTS_SCOPE],
    token_store
  )

  # Get user credentials
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)

  # If no valid credentials, prompt for authorization
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)

    puts "Open the following URL in your browser and authorize the application:"
    puts url
    puts "\nEnter the authorization code:"

    code = gets.chomp

    begin
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id,
        code: code,
        base_url: OOB_URI
      )
    rescue => e
      return {
        status: 'error',
        code: 'AUTH_ERROR',
        message: "Authorization failed: #{e.message}"
      }
    end
  end

  # Automatically refresh token if expired
  begin
    credentials.refresh! if credentials.expired?
  rescue => e
    return {
      status: 'error',
      code: 'AUTH_ERROR',
      message: "Token refresh failed: #{e.message}"
    }
  end

  credentials
end

# Look up contact email by name (for attendee resolution)
def lookup_contact_email(name_query, credentials)
  return nil if name_query.nil? || name_query.strip.empty?

  # If it looks like an email, return it as-is
  return name_query if name_query.include?('@')

  # Initialize People API service
  people_service = Google::Apis::PeopleV1::PeopleServiceService.new
  people_service.authorization = credentials

  # Split name into parts
  name_parts = name_query.strip.split(/\s+/)
  return nil if name_parts.length < 2

  query_first = name_parts.first.downcase
  query_last = name_parts.last.downcase

  begin
    response = people_service.list_person_connections(
      'people/me',
      person_fields: 'names,emailAddresses',
      page_size: 1000
    )

    if response.connections
      response.connections.each do |person|
        next unless person.names && person.email_addresses

        person.names.each do |name|
          if name.given_name&.downcase == query_first &&
             name.family_name&.downcase == query_last

            primary_email = person.email_addresses.find { |e| e.metadata&.primary }
            email = primary_email || person.email_addresses.first
            return email.value if email&.value
          end
        end
      end
    end
  rescue => e
    # Silently fail contact lookup, return nil
    return nil
  end

  nil
end

# List events from calendar
def list_events(options, credentials)
  service = Google::Apis::CalendarV3::CalendarService.new
  service.authorization = credentials

  calendar_id = options[:calendar_id] || 'primary'

  # Parse time range
  time_min = options[:time_min] ? Time.parse(options[:time_min]).iso8601 : Time.now.iso8601
  time_max = options[:time_max] ? Time.parse(options[:time_max]).iso8601 : nil

  begin
    response = service.list_events(
      calendar_id,
      max_results: options[:max_results] || 10,
      single_events: true,
      order_by: 'startTime',
      time_min: time_min,
      time_max: time_max
    )

    events = response.items.map do |event|
      {
        id: event.id,
        summary: event.summary,
        description: event.description,
        location: event.location,
        start: event.start.date_time || event.start.date,
        end: event.end.date_time || event.end.date,
        attendees: event.attendees&.map { |a| { email: a.email, response_status: a.response_status } },
        html_link: event.html_link,
        hangout_link: event.hangout_link,
        conference_data: event.conference_data
      }
    end

    {
      status: 'success',
      operation: 'list',
      count: events.length,
      events: events
    }
  rescue Google::Apis::Error => e
    {
      status: 'error',
      code: 'API_ERROR',
      message: "Failed to list events: #{e.message}"
    }
  end
end

# Create a new calendar event
def create_event(options, credentials)
  service = Google::Apis::CalendarV3::CalendarService.new
  service.authorization = credentials

  calendar_id = options[:calendar_id] || 'primary'

  # Build event object
  event = Google::Apis::CalendarV3::Event.new(
    summary: options[:summary],
    description: options[:description],
    location: options[:location]
  )

  # Parse and set start/end times
  begin
    start_time = Time.parse(options[:start_time])
    end_time = options[:end_time] ? Time.parse(options[:end_time]) : (start_time + 3600) # Default 1 hour

    event.start = Google::Apis::CalendarV3::EventDateTime.new(
      date_time: start_time.iso8601,
      time_zone: options[:timezone] || 'America/Chicago'
    )

    event.end = Google::Apis::CalendarV3::EventDateTime.new(
      date_time: end_time.iso8601,
      time_zone: options[:timezone] || 'America/Chicago'
    )
  rescue => e
    return {
      status: 'error',
      code: 'INVALID_TIME',
      message: "Failed to parse time: #{e.message}"
    }
  end

  # Add attendees if provided
  if options[:attendees]
    attendee_emails = options[:attendees].split(',').map(&:strip)
    resolved_emails = []

    attendee_emails.each do |attendee|
      # Try to resolve name to email via contacts
      email = lookup_contact_email(attendee, credentials)
      if email
        resolved_emails << email
      elsif attendee.include?('@')
        # Already an email
        resolved_emails << attendee
      else
        # Could not resolve
        return {
          status: 'error',
          code: 'ATTENDEE_NOT_FOUND',
          message: "Could not find email for attendee: #{attendee}"
        }
      end
    end

    event.attendees = resolved_emails.map { |email| Google::Apis::CalendarV3::EventAttendee.new(email: email) }
  end

  # Add Google Meet if requested
  if options[:google_meet]
    event.conference_data = Google::Apis::CalendarV3::ConferenceData.new(
      create_request: Google::Apis::CalendarV3::CreateConferenceRequest.new(
        request_id: "meet-#{Time.now.to_i}",
        conference_solution_key: Google::Apis::CalendarV3::ConferenceSolutionKey.new(
          type: 'hangoutsMeet'
        )
      )
    )
  end

  begin
    result = service.insert_event(
      calendar_id,
      event,
      conference_data_version: options[:google_meet] ? 1 : 0,
      send_notifications: true
    )

    {
      status: 'success',
      operation: 'create',
      event: {
        id: result.id,
        summary: result.summary,
        start: result.start.date_time,
        end: result.end.date_time,
        html_link: result.html_link,
        hangout_link: result.hangout_link,
        attendees: result.attendees&.map { |a| a.email }
      }
    }
  rescue Google::Apis::Error => e
    {
      status: 'error',
      code: 'API_ERROR',
      message: "Failed to create event: #{e.message}"
    }
  end
end

# Update an existing event
def update_event(options, credentials)
  service = Google::Apis::CalendarV3::CalendarService.new
  service.authorization = credentials

  calendar_id = options[:calendar_id] || 'primary'
  event_id = options[:event_id]

  begin
    # Get existing event
    event = service.get_event(calendar_id, event_id)

    # Update fields if provided
    event.summary = options[:summary] if options[:summary]
    event.description = options[:description] if options[:description]
    event.location = options[:location] if options[:location]

    # Update times if provided
    if options[:start_time]
      start_time = Time.parse(options[:start_time])
      event.start.date_time = start_time.iso8601
    end

    if options[:end_time]
      end_time = Time.parse(options[:end_time])
      event.end.date_time = end_time.iso8601
    end

    # Update event
    result = service.update_event(calendar_id, event_id, event, send_notifications: true)

    {
      status: 'success',
      operation: 'update',
      event: {
        id: result.id,
        summary: result.summary,
        start: result.start.date_time,
        end: result.end.date_time,
        html_link: result.html_link
      }
    }
  rescue Google::Apis::Error => e
    {
      status: 'error',
      code: 'API_ERROR',
      message: "Failed to update event: #{e.message}"
    }
  end
end

# Delete an event
def delete_event(options, credentials)
  service = Google::Apis::CalendarV3::CalendarService.new
  service.authorization = credentials

  calendar_id = options[:calendar_id] || 'primary'
  event_id = options[:event_id]

  begin
    service.delete_event(calendar_id, event_id, send_notifications: true)

    {
      status: 'success',
      operation: 'delete',
      event_id: event_id,
      message: 'Event deleted successfully'
    }
  rescue Google::Apis::Error => e
    {
      status: 'error',
      code: 'API_ERROR',
      message: "Failed to delete event: #{e.message}"
    }
  end
end

# Find free time slots
def find_free_time(options, credentials)
  service = Google::Apis::CalendarV3::CalendarService.new
  service.authorization = credentials

  calendar_id = options[:calendar_id] || 'primary'

  # Parse time range
  time_min = Time.parse(options[:time_min])
  time_max = Time.parse(options[:time_max])

  # Business hours: 9am-5pm
  business_start_hour = options[:business_start] || 9
  business_end_hour = options[:business_end] || 17

  begin
    # Get busy times via freebusy query
    request = Google::Apis::CalendarV3::FreeBusyRequest.new(
      time_min: time_min.iso8601,
      time_max: time_max.iso8601,
      items: [Google::Apis::CalendarV3::FreeBusyRequestItem.new(id: calendar_id)]
    )

    response = service.query_freebusy(request)
    busy_times = response.calendars[calendar_id].busy

    # Find free slots during business hours
    free_slots = []
    current = time_min

    while current < time_max
      # Skip if outside business hours
      if current.hour >= business_start_hour && current.hour < business_end_hour
        slot_end = current + (options[:duration] || 3600)

        # Check if this slot overlaps with any busy time
        is_free = busy_times.none? do |busy|
          busy_start = Time.parse(busy.start)
          busy_end = Time.parse(busy.end)

          (current >= busy_start && current < busy_end) ||
          (slot_end > busy_start && slot_end <= busy_end) ||
          (current <= busy_start && slot_end >= busy_end)
        end

        if is_free && slot_end.hour <= business_end_hour
          free_slots << {
            start: current.iso8601,
            end: slot_end.iso8601
          }
        end
      end

      current += (options[:interval] || 1800) # Default 30 min intervals
    end

    {
      status: 'success',
      operation: 'find_free_time',
      slots: free_slots.first(options[:max_results] || 5)
    }
  rescue Google::Apis::Error => e
    {
      status: 'error',
      code: 'API_ERROR',
      message: "Failed to find free time: #{e.message}"
    }
  end
end

# Parse command-line arguments
def parse_arguments
  options = {}

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename($0)} --operation <op> [options]"
    opts.separator ""
    opts.separator "Google Calendar Manager Script"
    opts.separator ""
    opts.separator "Operations:"

    opts.on("--operation OP", [:list, :create, :update, :delete, :find_free],
            "Operation: list, create, update, delete, find_free") do |op|
      options[:operation] = op
    end

    opts.separator ""
    opts.separator "Common options:"

    opts.on("--calendar-id ID", "Calendar ID (default: primary)") do |id|
      options[:calendar_id] = id
    end

    opts.on("--timezone TZ", "Timezone (default: America/Chicago)") do |tz|
      options[:timezone] = tz
    end

    opts.separator ""
    opts.separator "List options:"

    opts.on("--time-min TIME", "Start time for list (ISO8601 or natural)") do |t|
      options[:time_min] = t
    end

    opts.on("--time-max TIME", "End time for list") do |t|
      options[:time_max] = t
    end

    opts.on("--max-results N", Integer, "Max results (default: 10)") do |n|
      options[:max_results] = n
    end

    opts.separator ""
    opts.separator "Create/Update options:"

    opts.on("--event-id ID", "Event ID (for update/delete)") do |id|
      options[:event_id] = id
    end

    opts.on("--summary TEXT", "Event summary/title") do |text|
      options[:summary] = text
    end

    opts.on("--description TEXT", "Event description") do |text|
      options[:description] = text
    end

    opts.on("--location TEXT", "Event location") do |text|
      options[:location] = text
    end

    opts.on("--start-time TIME", "Start time (ISO8601 or natural)") do |t|
      options[:start_time] = t
    end

    opts.on("--end-time TIME", "End time") do |t|
      options[:end_time] = t
    end

    opts.on("--attendees EMAILS", "Comma-separated attendee emails or names") do |emails|
      options[:attendees] = emails
    end

    opts.on("--google-meet", "Add Google Meet link") do
      options[:google_meet] = true
    end

    opts.separator ""
    opts.separator "Find free time options:"

    opts.on("--duration SECONDS", Integer, "Duration in seconds (default: 3600)") do |d|
      options[:duration] = d
    end

    opts.on("--business-start HOUR", Integer, "Business hours start (default: 9)") do |h|
      options[:business_start] = h
    end

    opts.on("--business-end HOUR", Integer, "Business hours end (default: 17)") do |h|
      options[:business_end] = h
    end

    opts.on("--interval SECONDS", Integer, "Check interval (default: 1800)") do |i|
      options[:interval] = i
    end

    opts.separator ""
    opts.separator "Other options:"

    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit 0
    end

    opts.on("-v", "--version", "Show version") do
      puts "Google Calendar Manager - Version #{VERSION}"
      exit 0
    end
  end

  begin
    parser.parse!

    if options[:operation].nil?
      puts "Error: --operation is required"
      puts parser
      exit 4
    end

  rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
    puts "Error: #{e.message}"
    puts parser
    exit 4
  end

  options
end

# Main execution
if __FILE__ == $0
  options = parse_arguments

  # Authorize
  credentials = authorize

  # Check for auth errors
  if credentials.is_a?(Hash) && credentials[:status] == 'error'
    puts JSON.generate(credentials)
    exit 2
  end

  # Execute operation
  result = case options[:operation]
           when :list
             list_events(options, credentials)
           when :create
             create_event(options, credentials)
           when :update
             update_event(options, credentials)
           when :delete
             delete_event(options, credentials)
           when :find_free
             find_free_time(options, credentials)
           else
             {
               status: 'error',
               code: 'INVALID_OPERATION',
               message: "Unknown operation: #{options[:operation]}"
             }
           end

  # Output result
  puts JSON.generate(result)

  # Exit with appropriate code
  case result[:status]
  when 'success'
    exit 0
  when 'error'
    case result[:code]
    when 'AUTH_ERROR'
      exit 2
    when 'API_ERROR'
      exit 3
    else
      exit 1
    end
  else
    exit 1
  end
end
