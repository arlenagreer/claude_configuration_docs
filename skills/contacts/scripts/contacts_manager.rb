#!/usr/bin/env ruby
# frozen_string_literal: true
# Ruby 3.3.7 required for google-apis-people_v1 gem

# Google Contacts Manager Script
#
# Purpose: Manage Google Contacts with full CRUD operations
# Usage: See --help for detailed command examples
# Output: JSON with results or error information
# Exit codes: 0=success, 1=operation failed, 2=auth error, 3=api error, 4=invalid args

require 'optparse'
require 'json'
require 'fileutils'
require 'google/apis/people_v1'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

# Script version
VERSION = '1.1.0'

# Configuration constants
CONTACTS_SCOPE = Google::Apis::PeopleV1::AUTH_CONTACTS
CALENDAR_SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
CREDENTIALS_PATH = File.join(Dir.home, '.claude', '.google', 'client_secret.json')
TOKEN_PATH = File.join(Dir.home, '.claude', '.google', 'token.json')
OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

# Authorize with Google OAuth 2.0
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

  # Create token store with both calendar and contacts scopes
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

# Initialize People service
def init_service
  credentials = authorize
  return credentials if credentials.is_a?(Hash) && credentials[:status] == 'error'

  service = Google::Apis::PeopleV1::PeopleServiceService.new
  service.authorization = credentials
  service
end

# Normalize phone number to digits only for comparison
# Also removes leading '1' (US country code) for better matching
def normalize_phone(phone)
  return '' if phone.nil?
  # Remove all non-digit characters
  digits = phone.gsub(/\D/, '')
  # Remove leading '1' if present (US country code)
  # This allows matching "+1 (619) 846-1019" with "619-846-1019"
  digits = digits.sub(/^1/, '') if digits.length == 11 && digits.start_with?('1')
  digits
end

# Normalize text by removing diacritics/accents for accent-insensitive matching
# This allows "Zoe" to match "Zoë", "Jose" to match "José", etc.
def normalize_diacritics(text)
  return '' if text.nil?
  # Use Unicode normalization (NFD) to decompose characters, then remove combining marks
  text.unicode_normalize(:nfd).gsub(/\p{Mn}/, '')
end

# Search contacts by name, email, or phone (client-side filtering)
def search_contacts(service, query)
  begin
    # List all contacts and filter client-side
    response = service.list_person_connections(
      'people/me',
      person_fields: 'names,emailAddresses,phoneNumbers,organizations,birthdays,addresses,biographies,urls',
      page_size: 1000  # Get up to 1000 contacts for search
    )

    contacts = []
    query_lower = query.downcase
    # Normalize query for phone number search (remove all non-digits)
    query_normalized = normalize_phone(query)
    # Normalize query for accent-insensitive name matching
    query_normalized_accents = normalize_diacritics(query_lower)

    if response.connections
      response.connections.each do |person|
        # Search in display name, given name, family name, email, and phone
        match = false

        # Search in names (with accent-insensitive matching)
        if person.names && !person.names.empty?
          name = person.names.first
          # Check both exact match and accent-normalized match
          match = true if name.display_name&.downcase&.include?(query_lower)
          match = true if name.given_name&.downcase&.include?(query_lower)
          match = true if name.family_name&.downcase&.include?(query_lower)
          # Also check accent-normalized versions
          match = true if normalize_diacritics(name.display_name&.downcase || '').include?(query_normalized_accents)
          match = true if normalize_diacritics(name.given_name&.downcase || '').include?(query_normalized_accents)
          match = true if normalize_diacritics(name.family_name&.downcase || '').include?(query_normalized_accents)
        end

        # Search in email addresses
        if !match && person.email_addresses && !person.email_addresses.empty?
          person.email_addresses.each do |email|
            match = true if email.value&.downcase&.include?(query_lower)
          end
        end

        # Search in phone numbers (normalize both query and stored numbers)
        if !match && person.phone_numbers && !person.phone_numbers.empty? && !query_normalized.empty?
          person.phone_numbers.each do |phone|
            normalized_phone = normalize_phone(phone.value)
            # Match if the normalized query is contained in the normalized phone number
            # This handles cases like searching "6198461019" or "+16198461019" or "(619) 846-1019"
            match = true if normalized_phone.include?(query_normalized)
          end
        end

        contacts << format_contact(person) if match
      end
    end

    {
      status: 'success',
      count: contacts.length,
      contacts: contacts
    }
  rescue => e
    {
      status: 'error',
      code: 'API_ERROR',
      message: "Search failed: #{e.message}"
    }
  end
end

# Get contact by resource name
def get_contact(service, resource_name)
  begin
    person = service.get_person(
      resource_name,
      person_fields: 'names,emailAddresses,phoneNumbers,organizations,birthdays,addresses,biographies,urls,metadata'
    )

    {
      status: 'success',
      contact: format_contact(person)
    }
  rescue => e
    {
      status: 'error',
      code: 'API_ERROR',
      message: "Get contact failed: #{e.message}"
    }
  end
end

# List contacts with optional filtering
def list_contacts(service, page_size = 100, page_token = nil)
  begin
    response = service.list_person_connections(
      'people/me',
      person_fields: 'names,emailAddresses,phoneNumbers,organizations,birthdays,addresses,biographies,urls',
      page_size: page_size,
      page_token: page_token
    )

    contacts = []
    if response.connections
      response.connections.each do |person|
        contacts << format_contact(person)
      end
    end

    {
      status: 'success',
      count: contacts.length,
      contacts: contacts,
      next_page_token: response.next_page_token
    }
  rescue => e
    {
      status: 'error',
      code: 'API_ERROR',
      message: "List contacts failed: #{e.message}"
    }
  end
end

# Create new contact
def create_contact(service, data)
  begin
    person = Google::Apis::PeopleV1::Person.new

    # Add names
    if data['name']
      person.names = [
        Google::Apis::PeopleV1::Name.new(
          given_name: data['name']['given_name'],
          family_name: data['name']['family_name'],
          display_name: data['name']['display_name']
        )
      ]
    end

    # Add emails
    if data['emails']
      person.email_addresses = data['emails'].map do |email|
        Google::Apis::PeopleV1::EmailAddress.new(
          value: email['value'],
          type: email['type'] || 'home'
        )
      end
    end

    # Add phone numbers
    if data['phones']
      person.phone_numbers = data['phones'].map do |phone|
        Google::Apis::PeopleV1::PhoneNumber.new(
          value: phone['value'],
          type: phone['type'] || 'mobile'
        )
      end
    end

    # Add organization
    if data['organization']
      person.organizations = [
        Google::Apis::PeopleV1::Organization.new(
          name: data['organization']['name'],
          title: data['organization']['title']
        )
      ]
    end

    # Add birthday
    if data['birthday']
      person.birthdays = [
        Google::Apis::PeopleV1::Birthday.new(
          date: Google::Apis::PeopleV1::Date.new(
            year: data['birthday']['year'],
            month: data['birthday']['month'],
            day: data['birthday']['day']
          )
        )
      ]
    end

    # Add addresses
    if data['addresses']
      person.addresses = data['addresses'].map do |address|
        Google::Apis::PeopleV1::Address.new(
          street_address: address['street'],
          city: address['city'],
          region: address['state'],
          postal_code: address['zip'],
          country: address['country'],
          type: address['type'] || 'home'
        )
      end
    end

    # Add notes/biography
    if data['notes']
      person.biographies = [
        Google::Apis::PeopleV1::Biography.new(
          value: data['notes']
        )
      ]
    end

    created_person = service.create_person_contact(person)

    {
      status: 'success',
      message: 'Contact created successfully',
      contact: format_contact(created_person)
    }
  rescue => e
    {
      status: 'error',
      code: 'API_ERROR',
      message: "Create contact failed: #{e.message}"
    }
  end
end

# Update existing contact
def update_contact(service, resource_name, data, update_mask)
  begin
    # First get the current contact
    person = service.get_person(
      resource_name,
      person_fields: 'names,emailAddresses,phoneNumbers,organizations,birthdays,addresses,biographies,urls,metadata'
    )

    # Update fields based on data provided
    if data['name']
      person.names ||= []
      if person.names.empty?
        person.names << Google::Apis::PeopleV1::Name.new
      end
      person.names[0].given_name = data['name']['given_name'] if data['name']['given_name']
      person.names[0].family_name = data['name']['family_name'] if data['name']['family_name']
      person.names[0].display_name = data['name']['display_name'] if data['name']['display_name']
    end

    if data['emails']
      person.email_addresses = data['emails'].map do |email|
        Google::Apis::PeopleV1::EmailAddress.new(
          value: email['value'],
          type: email['type'] || 'home'
        )
      end
    end

    if data['phones']
      person.phone_numbers = data['phones'].map do |phone|
        Google::Apis::PeopleV1::PhoneNumber.new(
          value: phone['value'],
          type: phone['type'] || 'mobile'
        )
      end
    end

    if data['organization']
      person.organizations ||= []
      if person.organizations.empty?
        person.organizations << Google::Apis::PeopleV1::Organization.new
      end
      person.organizations[0].name = data['organization']['name'] if data['organization']['name']
      person.organizations[0].title = data['organization']['title'] if data['organization']['title']
    end

    if data['birthday']
      person.birthdays ||= []
      if person.birthdays.empty?
        person.birthdays << Google::Apis::PeopleV1::Birthday.new(
          date: Google::Apis::PeopleV1::Date.new
        )
      end
      person.birthdays[0].date.year = data['birthday']['year'] if data['birthday']['year']
      person.birthdays[0].date.month = data['birthday']['month'] if data['birthday']['month']
      person.birthdays[0].date.day = data['birthday']['day'] if data['birthday']['day']
    end

    if data['addresses']
      person.addresses = data['addresses'].map do |address|
        Google::Apis::PeopleV1::Address.new(
          street_address: address['street'],
          city: address['city'],
          region: address['state'],
          postal_code: address['zip'],
          country: address['country'],
          type: address['type'] || 'home'
        )
      end
    end

    if data['notes']
      person.biographies ||= []
      if person.biographies.empty?
        person.biographies << Google::Apis::PeopleV1::Biography.new
      end
      person.biographies[0].value = data['notes']
    end

    updated_person = service.update_person_contact(
      resource_name,
      person,
      update_person_fields: update_mask
    )

    {
      status: 'success',
      message: 'Contact updated successfully',
      contact: format_contact(updated_person)
    }
  rescue => e
    {
      status: 'error',
      code: 'API_ERROR',
      message: "Update contact failed: #{e.message}"
    }
  end
end

# Delete contact
def delete_contact(service, resource_name)
  begin
    service.delete_person_contact(resource_name)

    {
      status: 'success',
      message: 'Contact deleted successfully',
      resource_name: resource_name
    }
  rescue => e
    {
      status: 'error',
      code: 'API_ERROR',
      message: "Delete contact failed: #{e.message}"
    }
  end
end

# Format contact data for output
def format_contact(person)
  contact = {
    resource_name: person.resource_name
  }

  # Names
  if person.names && !person.names.empty?
    name = person.names.first
    contact[:name] = {
      display_name: name.display_name,
      given_name: name.given_name,
      family_name: name.family_name
    }
  end

  # Email addresses
  if person.email_addresses && !person.email_addresses.empty?
    contact[:emails] = person.email_addresses.map do |email|
      {
        value: email.value,
        type: email.type
      }
    end
  end

  # Phone numbers
  if person.phone_numbers && !person.phone_numbers.empty?
    contact[:phones] = person.phone_numbers.map do |phone|
      {
        value: phone.value,
        type: phone.type
      }
    end
  end

  # Organizations
  if person.organizations && !person.organizations.empty?
    org = person.organizations.first
    contact[:organization] = {
      name: org.name,
      title: org.title
    }
  end

  # Birthdays
  if person.birthdays && !person.birthdays.empty?
    birthday = person.birthdays.first
    if birthday.date
      contact[:birthday] = {
        year: birthday.date.year,
        month: birthday.date.month,
        day: birthday.date.day
      }
    end
  end

  # Addresses
  if person.addresses && !person.addresses.empty?
    contact[:addresses] = person.addresses.map do |address|
      {
        street: address.street_address,
        city: address.city,
        state: address.region,
        zip: address.postal_code,
        country: address.country,
        type: address.type
      }
    end
  end

  # Biography/Notes
  if person.biographies && !person.biographies.empty?
    contact[:notes] = person.biographies.first.value
  end

  # URLs
  if person.urls && !person.urls.empty?
    contact[:urls] = person.urls.map do |url|
      {
        value: url.value,
        type: url.type
      }
    end
  end

  contact
end

# Main execution
def main
  options = {}

  OptionParser.new do |opts|
    opts.banner = "Usage: contacts_manager.rb [options]"

    opts.on("--search QUERY", "Search contacts by name") do |q|
      options[:action] = :search
      options[:query] = q
    end

    opts.on("--get RESOURCE_NAME", "Get contact by resource name") do |r|
      options[:action] = :get
      options[:resource_name] = r
    end

    opts.on("--list", "List all contacts") do
      options[:action] = :list
    end

    opts.on("--page-size SIZE", Integer, "Number of contacts per page (default: 100)") do |s|
      options[:page_size] = s
    end

    opts.on("--page-token TOKEN", "Page token for pagination") do |t|
      options[:page_token] = t
    end

    opts.on("--create DATA", "Create new contact (JSON)") do |d|
      options[:action] = :create
      options[:data] = JSON.parse(d)
    end

    opts.on("--update RESOURCE_NAME", "Update contact by resource name") do |r|
      options[:action] = :update
      options[:resource_name] = r
    end

    opts.on("--update-data DATA", "Update data (JSON)") do |d|
      options[:update_data] = JSON.parse(d)
    end

    opts.on("--update-mask MASK", "Update mask (comma-separated fields)") do |m|
      options[:update_mask] = m
    end

    opts.on("--delete RESOURCE_NAME", "Delete contact by resource name") do |r|
      options[:action] = :delete
      options[:resource_name] = r
    end

    opts.on("-v", "--version", "Show version") do
      puts "Google Contacts Manager - Version #{VERSION}"
      exit 0
    end

    opts.on("-h", "--help", "Show this help message") do
      puts opts
      puts "\nExamples:"
      puts "  Search: contacts_manager.rb --search 'John Smith'"
      puts "  List:   contacts_manager.rb --list --page-size 50"
      puts "  Get:    contacts_manager.rb --get 'people/c1234567890'"
      puts "  Create: contacts_manager.rb --create '{\"name\":{\"given_name\":\"John\",\"family_name\":\"Doe\"},\"emails\":[{\"value\":\"john@example.com\"}]}'"
      puts "  Update: contacts_manager.rb --update 'people/c1234567890' --update-data '{\"phones\":[{\"value\":\"555-1234\"}]}' --update-mask 'phoneNumbers'"
      puts "  Delete: contacts_manager.rb --delete 'people/c1234567890'"
      exit 0
    end
  end.parse!

  # Initialize service
  service = init_service
  if service.is_a?(Hash) && service[:status] == 'error'
    puts JSON.pretty_generate(service)
    exit 2
  end

  # Execute action
  result = case options[:action]
  when :search
    search_contacts(service, options[:query])
  when :get
    get_contact(service, options[:resource_name])
  when :list
    list_contacts(service, options[:page_size] || 100, options[:page_token])
  when :create
    create_contact(service, options[:data])
  when :update
    update_contact(service, options[:resource_name], options[:update_data], options[:update_mask])
  when :delete
    delete_contact(service, options[:resource_name])
  else
    {
      status: 'error',
      code: 'INVALID_ARGS',
      message: 'No action specified. Use --help for usage information.'
    }
  end

  puts JSON.pretty_generate(result)
  exit(result[:status] == 'success' ? 0 : 1)
end

main if __FILE__ == $PROGRAM_NAME
