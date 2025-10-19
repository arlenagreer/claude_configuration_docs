#!/usr/bin/env ruby

require 'google/apis/people_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

# Configuration
SCOPE = Google::Apis::PeopleV1::AUTH_CONTACTS_READONLY
CREDENTIALS_PATH = File.join(Dir.home, '.claude', '.google', 'client_secret.json')
TOKEN_PATH = File.join(Dir.home, '.claude', '.google', 'token.json')
OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

# Get authorization code from command line
auth_code = ARGV[0]

if auth_code.nil? || auth_code.empty?
  puts "Usage: #{$0} <authorization_code>"
  exit 1
end

# Load client secrets
client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)

# Create token store
token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)

# Exchange authorization code for tokens
begin
  credentials = authorizer.get_and_store_credentials_from_code(
    user_id: 'default',
    code: auth_code,
    base_url: OOB_URI
  )

  puts "✅ Authorization successful!"
  puts "Token saved to: #{TOKEN_PATH}"
  puts "\nYou can now use the lookup_contact_email.rb script."
rescue => e
  puts "❌ Authorization failed: #{e.message}"
  exit 1
end
