#!/usr/bin/env ruby
# frozen_string_literal: true

require 'google/apis/drive_v3'
require 'google/apis/sheets_v4'
require 'google/apis/docs_v1'
require 'google/apis/calendar_v3'
require 'google/apis/people_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'json'
require 'mime/types'

# Drive Manager - Google CLI Integration for Drive Operations
# Version: 1.0.0
# Scopes: Drive, Sheets, Docs, Calendar, Contacts, Gmail
class DriveManager
  # OAuth scopes - ALL Google skills share these
  DRIVE_SCOPE = Google::Apis::DriveV3::AUTH_DRIVE
  SHEETS_SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS
  DOCS_SCOPE = Google::Apis::DocsV1::AUTH_DOCUMENTS
  CALENDAR_SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
  CONTACTS_SCOPE = Google::Apis::PeopleV1::AUTH_CONTACTS
  GMAIL_SCOPE = 'https://www.googleapis.com/auth/gmail.modify'

  CREDENTIALS_PATH = File.join(Dir.home, '.claude', '.google', 'client_secret.json')
  TOKEN_PATH = File.join(Dir.home, '.claude', '.google', 'token.json')

  # Exit codes
  EXIT_SUCCESS = 0
  EXIT_OPERATION_FAILED = 1
  EXIT_AUTH_ERROR = 2
  EXIT_API_ERROR = 3
  EXIT_INVALID_ARGS = 4

  def initialize
    @service = Google::Apis::DriveV3::DriveService.new
    @service.client_options.application_name = 'Claude Drive Skill'
    @service.authorization = authorize
  end

  # Authorize using shared OAuth token with all scopes
  def authorize
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)

    # Include ALL scopes for shared token
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id,
      [DRIVE_SCOPE, SHEETS_SCOPE, DOCS_SCOPE, CALENDAR_SCOPE, CONTACTS_SCOPE, GMAIL_SCOPE],
      token_store
    )

    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)

    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: 'urn:ietf:wg:oauth:2.0:oob')
      output_json({
        status: 'error',
        error_code: 'AUTH_REQUIRED',
        message: 'Authorization required. Please visit the URL and enter the code.',
        auth_url: url,
        instructions: [
          '1. Visit the authorization URL',
          '2. Grant access to Drive, Sheets, Docs, Calendar, Contacts, and Gmail',
          '3. Copy the authorization code',
          "4. Run: ruby #{__FILE__} auth <code>"
        ]
      })
      exit EXIT_AUTH_ERROR
    end

    # Auto-refresh expired tokens
    credentials.refresh! if credentials.expired?
    credentials
  end

  # Complete OAuth authorization with code
  def complete_auth(code)
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)

    authorizer = Google::Auth::UserAuthorizer.new(
      client_id,
      [DRIVE_SCOPE, SHEETS_SCOPE, DOCS_SCOPE, CALENDAR_SCOPE, CONTACTS_SCOPE, GMAIL_SCOPE],
      token_store
    )

    user_id = 'default'
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id,
      code: code,
      base_url: 'urn:ietf:wg:oauth:2.0:oob'
    )

    output_json({
      status: 'success',
      message: 'Authorization complete. Token stored successfully.',
      token_path: TOKEN_PATH,
      scopes: [DRIVE_SCOPE, SHEETS_SCOPE, DOCS_SCOPE, CALENDAR_SCOPE, CONTACTS_SCOPE, GMAIL_SCOPE]
    })
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'AUTH_FAILED',
      message: "Authorization failed: #{e.message}"
    })
    exit EXIT_AUTH_ERROR
  end

  # List files
  def list_files(max_results: 100, page_token: nil, folder_id: nil, fields: nil)
    query = folder_id ? "'#{folder_id}' in parents and trashed=false" : "trashed=false"

    file_fields = fields || 'id,name,mimeType,size,createdTime,modifiedTime,webViewLink,owners'

    result = @service.list_files(
      page_size: max_results,
      page_token: page_token,
      q: query,
      fields: "nextPageToken, files(#{file_fields})"
    )

    output_json({
      status: 'success',
      operation: 'list',
      count: result.files.length,
      next_page_token: result.next_page_token,
      files: result.files.map { |f| format_file(f) }
    })
  rescue Google::Apis::Error => e
    handle_api_error('list', e)
  rescue StandardError => e
    handle_error('list', e)
  end

  # Search files
  def search_files(query:, max_results: 100)
    result = @service.list_files(
      page_size: max_results,
      q: "#{query} and trashed=false",
      fields: 'files(id,name,mimeType,size,createdTime,modifiedTime,webViewLink,owners)'
    )

    output_json({
      status: 'success',
      operation: 'search',
      query: query,
      count: result.files.length,
      files: result.files.map { |f| format_file(f) }
    })
  rescue Google::Apis::Error => e
    handle_api_error('search', e)
  rescue StandardError => e
    handle_error('search', e)
  end

  # Get file details
  def get_file(file_id:)
    file = @service.get_file(
      file_id,
      fields: 'id,name,mimeType,size,createdTime,modifiedTime,webViewLink,downloadUrl,owners,permissions'
    )

    output_json({
      status: 'success',
      operation: 'get',
      file: format_file(file, include_permissions: true)
    })
  rescue Google::Apis::Error => e
    handle_api_error('get', e)
  rescue StandardError => e
    handle_error('get', e)
  end

  # Upload file
  def upload_file(file_path:, name: nil, parent_id: nil, description: nil)
    unless File.exist?(file_path)
      output_json({
        status: 'error',
        error_code: 'FILE_NOT_FOUND',
        operation: 'upload',
        message: "Local file not found: #{file_path}"
      })
      exit EXIT_OPERATION_FAILED
    end

    file_name = name || File.basename(file_path)
    mime_type = MIME::Types.type_for(file_path).first&.content_type || 'application/octet-stream'

    file_metadata = Google::Apis::DriveV3::File.new(
      name: file_name,
      description: description
    )
    file_metadata.parents = [parent_id] if parent_id

    file = @service.create_file(
      file_metadata,
      fields: 'id,name,mimeType,size,webViewLink',
      upload_source: file_path,
      content_type: mime_type
    )

    output_json({
      status: 'success',
      operation: 'upload',
      file: format_file(file)
    })
  rescue Google::Apis::Error => e
    handle_api_error('upload', e)
  rescue StandardError => e
    handle_error('upload', e)
  end

  # Download file
  def download_file(file_id:, output_path: nil)
    file = @service.get_file(file_id, fields: 'name,mimeType')

    output_file = output_path || file.name

    # Check if it's a Google Workspace file that needs export
    if file.mime_type.start_with?('application/vnd.google-apps.')
      export_mime_type = get_export_mime_type(file.mime_type)
      output_file = "#{output_file}.#{get_extension(export_mime_type)}" unless output_path

      @service.export_file(file_id, export_mime_type, download_dest: output_file)
    else
      @service.get_file(file_id, download_dest: output_file)
    end

    output_json({
      status: 'success',
      operation: 'download',
      file_id: file_id,
      output_path: File.expand_path(output_file),
      size: File.size(output_file)
    })
  rescue Google::Apis::Error => e
    handle_api_error('download', e)
  rescue StandardError => e
    handle_error('download', e)
  end

  # Export file to specific format
  def export_file(file_id:, mime_type:, output_path:)
    @service.export_file(file_id, mime_type, download_dest: output_path)

    output_json({
      status: 'success',
      operation: 'export',
      file_id: file_id,
      mime_type: mime_type,
      output_path: File.expand_path(output_path),
      size: File.size(output_path)
    })
  rescue Google::Apis::Error => e
    handle_api_error('export', e)
  rescue StandardError => e
    handle_error('export', e)
  end

  # Create folder
  def create_folder(name:, parent_id: nil)
    folder_metadata = Google::Apis::DriveV3::File.new(
      name: name,
      mime_type: 'application/vnd.google-apps.folder'
    )
    folder_metadata.parents = [parent_id] if parent_id

    folder = @service.create_file(
      folder_metadata,
      fields: 'id,name,mimeType,webViewLink'
    )

    output_json({
      status: 'success',
      operation: 'create_folder',
      folder: format_file(folder)
    })
  rescue Google::Apis::Error => e
    handle_api_error('create_folder', e)
  rescue StandardError => e
    handle_error('create_folder', e)
  end

  # Update file
  def update_file(file_id:, name: nil, description: nil)
    file_metadata = Google::Apis::DriveV3::File.new
    file_metadata.name = name if name
    file_metadata.description = description if description

    file = @service.update_file(
      file_id,
      file_metadata,
      fields: 'id,name,mimeType,modifiedTime,webViewLink'
    )

    output_json({
      status: 'success',
      operation: 'update',
      file: format_file(file)
    })
  rescue Google::Apis::Error => e
    handle_api_error('update', e)
  rescue StandardError => e
    handle_error('update', e)
  end

  # Move file
  def move_file(file_id:, new_parent_id:)
    file = @service.get_file(file_id, fields: 'parents')
    previous_parents = file.parents&.join(',')

    file = @service.update_file(
      file_id,
      nil,
      add_parents: new_parent_id,
      remove_parents: previous_parents,
      fields: 'id,name,parents,webViewLink'
    )

    output_json({
      status: 'success',
      operation: 'move',
      file: format_file(file)
    })
  rescue Google::Apis::Error => e
    handle_api_error('move', e)
  rescue StandardError => e
    handle_error('move', e)
  end

  # Delete file
  def delete_file(file_id:, permanent: false)
    if permanent
      @service.delete_file(file_id)
      message = 'File permanently deleted'
    else
      file_metadata = Google::Apis::DriveV3::File.new(trashed: true)
      @service.update_file(file_id, file_metadata)
      message = 'File moved to trash'
    end

    output_json({
      status: 'success',
      operation: 'delete',
      file_id: file_id,
      permanent: permanent,
      message: message
    })
  rescue Google::Apis::Error => e
    handle_api_error('delete', e)
  rescue StandardError => e
    handle_error('delete', e)
  end

  # Share file
  def share_file(file_id:, email: nil, role: 'reader', type: 'user')
    permission = Google::Apis::DriveV3::Permission.new(
      type: type,
      role: role
    )
    permission.email_address = email if email && type == 'user'

    result = @service.create_permission(
      file_id,
      permission,
      fields: 'id,type,role,emailAddress'
    )

    output_json({
      status: 'success',
      operation: 'share',
      file_id: file_id,
      permission: {
        id: result.id,
        type: result.type,
        role: result.role,
        email: result.email_address
      }
    })
  rescue Google::Apis::Error => e
    handle_api_error('share', e)
  rescue StandardError => e
    handle_error('share', e)
  end

  # List permissions
  def list_permissions(file_id:)
    permissions = @service.list_permissions(
      file_id,
      fields: 'permissions(id,type,role,emailAddress,displayName)'
    )

    output_json({
      status: 'success',
      operation: 'permissions',
      file_id: file_id,
      count: permissions.permissions.length,
      permissions: permissions.permissions.map do |p|
        {
          id: p.id,
          type: p.type,
          role: p.role,
          email: p.email_address,
          display_name: p.display_name
        }
      end
    })
  rescue Google::Apis::Error => e
    handle_api_error('permissions', e)
  rescue StandardError => e
    handle_error('permissions', e)
  end

  # Remove permission
  def remove_permission(file_id:, permission_id:)
    @service.delete_permission(file_id, permission_id)

    output_json({
      status: 'success',
      operation: 'remove_permission',
      file_id: file_id,
      permission_id: permission_id,
      message: 'Permission removed successfully'
    })
  rescue Google::Apis::Error => e
    handle_api_error('remove_permission', e)
  rescue StandardError => e
    handle_error('remove_permission', e)
  end

  private

  # Format file object
  def format_file(file, include_permissions: false)
    formatted = {
      id: file.id,
      name: file.name,
      mime_type: file.mime_type,
      web_view_link: file.web_view_link
    }

    formatted[:size] = file.size.to_i if file.size
    formatted[:created_time] = file.created_time if file.created_time
    formatted[:modified_time] = file.modified_time if file.modified_time
    formatted[:owners] = file.owners.map { |o| o.display_name } if file.owners
    formatted[:permissions] = file.permissions if include_permissions && file.permissions

    formatted
  end

  # Get default export MIME type for Google Workspace files
  def get_export_mime_type(google_mime_type)
    case google_mime_type
    when 'application/vnd.google-apps.document'
      'application/pdf'
    when 'application/vnd.google-apps.spreadsheet'
      'text/csv'
    when 'application/vnd.google-apps.presentation'
      'application/pdf'
    else
      'application/pdf'
    end
  end

  # Get file extension from MIME type
  def get_extension(mime_type)
    case mime_type
    when 'application/pdf' then 'pdf'
    when 'text/csv' then 'csv'
    when 'text/plain' then 'txt'
    when 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' then 'docx'
    when 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' then 'xlsx'
    else 'pdf'
    end
  end

  # Handle API errors
  def handle_api_error(operation, error)
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: operation,
      message: "Drive API error: #{error.message}",
      details: error.body
    })
    exit EXIT_API_ERROR
  end

  # Handle general errors
  def handle_error(operation, error)
    output_json({
      status: 'error',
      error_code: 'OPERATION_FAILED',
      operation: operation,
      message: "Failed: #{error.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Output JSON to stdout
  def output_json(data)
    puts JSON.pretty_generate(data)
  end
end

# CLI Interface
def usage
  puts <<~USAGE
    Drive Manager - Google CLI Integration for Drive Operations
    Version: 1.0.0

    Usage:
      #{File.basename($PROGRAM_NAME)} <command> [options]

    Commands:
      auth <code>              Complete OAuth authorization with code
      list                     List files
      search --query <query>   Search files
      get --file-id <id>       Get file details
      upload --file-path <path> [--name <name>] [--parent-id <id>]
      download --file-id <id> [--output-path <path>]
      export --file-id <id> --mime-type <type> --output-path <path>
      create-folder --name <name> [--parent-id <id>]
      update --file-id <id> [--name <name>] [--description <desc>]
      move --file-id <id> --new-parent-id <id>
      delete --file-id <id> [--permanent]
      share --file-id <id> [--email <email>] --role <role> [--type <type>]
      permissions --file-id <id>
      remove-permission --file-id <id> --permission-id <id>

    Examples:
      # Complete OAuth
      #{File.basename($PROGRAM_NAME)} auth YOUR_CODE

      # List files
      #{File.basename($PROGRAM_NAME)} list

      # Search for PDFs
      #{File.basename($PROGRAM_NAME)} search --query "mimeType='application/pdf'"

      # Upload file
      #{File.basename($PROGRAM_NAME)} upload --file-path /path/to/file.pdf --name "Report.pdf"

      # Download file
      #{File.basename($PROGRAM_NAME)} download --file-id FILE_ID --output-path /path/to/save.pdf

      # Export Sheet to CSV
      #{File.basename($PROGRAM_NAME)} export --file-id FILE_ID --mime-type "text/csv" --output-path data.csv

      # Create folder
      #{File.basename($PROGRAM_NAME)} create-folder --name "Project Files"

      # Share file
      #{File.basename($PROGRAM_NAME)} share --file-id FILE_ID --email user@example.com --role reader

    Exit Codes:
      0 - Success
      1 - Operation failed
      2 - Authentication error
      3 - API error
      4 - Invalid arguments
  USAGE
end

# Parse command line arguments
def parse_args(args)
  options = {}
  i = 0
  while i < args.length
    case args[i]
    when '--file-id' then options[:file_id] = args[i + 1]
    when '--file-path' then options[:file_path] = args[i + 1]
    when '--name' then options[:name] = args[i + 1]
    when '--description' then options[:description] = args[i + 1]
    when '--parent-id' then options[:parent_id] = args[i + 1]
    when '--new-parent-id' then options[:new_parent_id] = args[i + 1]
    when '--output-path' then options[:output_path] = args[i + 1]
    when '--query' then options[:query] = args[i + 1]
    when '--mime-type' then options[:mime_type] = args[i + 1]
    when '--email' then options[:email] = args[i + 1]
    when '--role' then options[:role] = args[i + 1]
    when '--type' then options[:type] = args[i + 1]
    when '--permission-id' then options[:permission_id] = args[i + 1]
    when '--max-results' then options[:max_results] = args[i + 1].to_i
    when '--page-token' then options[:page_token] = args[i + 1]
    when '--folder-id' then options[:folder_id] = args[i + 1]
    when '--fields' then options[:fields] = args[i + 1]
    when '--permanent' then options[:permanent] = true; i -= 1
    end
    i += 2
  end
  options
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    usage
    exit DriveManager::EXIT_INVALID_ARGS
  end

  command = ARGV[0]

  # Handle auth command separately
  if command == 'auth'
    if ARGV.length < 2
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_CODE',
        message: 'Authorization code required',
        usage: "#{File.basename($PROGRAM_NAME)} auth <code>"
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end

    temp_manager = DriveManager.allocate
    temp_manager.complete_auth(ARGV[1])
    exit DriveManager::EXIT_SUCCESS
  end

  # For all other commands, create manager
  manager = DriveManager.new
  options = parse_args(ARGV[1..-1])

  case command
  when 'list'
    manager.list_files(
      max_results: options[:max_results] || 100,
      page_token: options[:page_token],
      folder_id: options[:folder_id],
      fields: options[:fields]
    )

  when 'search'
    unless options[:query]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_QUERY',
        message: 'Search query required'
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end
    manager.search_files(query: options[:query], max_results: options[:max_results] || 100)

  when 'get'
    unless options[:file_id]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_FILE_ID',
        message: 'File ID required'
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end
    manager.get_file(file_id: options[:file_id])

  when 'upload'
    unless options[:file_path]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_FILE_PATH',
        message: 'File path required'
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end
    manager.upload_file(
      file_path: options[:file_path],
      name: options[:name],
      parent_id: options[:parent_id],
      description: options[:description]
    )

  when 'download'
    unless options[:file_id]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_FILE_ID',
        message: 'File ID required'
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end
    manager.download_file(
      file_id: options[:file_id],
      output_path: options[:output_path]
    )

  when 'export'
    unless options[:file_id] && options[:mime_type] && options[:output_path]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_ARGUMENTS',
        message: 'File ID, MIME type, and output path required'
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end
    manager.export_file(
      file_id: options[:file_id],
      mime_type: options[:mime_type],
      output_path: options[:output_path]
    )

  when 'create-folder'
    unless options[:name]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_NAME',
        message: 'Folder name required'
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end
    manager.create_folder(
      name: options[:name],
      parent_id: options[:parent_id]
    )

  when 'update'
    unless options[:file_id]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_FILE_ID',
        message: 'File ID required'
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end
    manager.update_file(
      file_id: options[:file_id],
      name: options[:name],
      description: options[:description]
    )

  when 'move'
    unless options[:file_id] && options[:new_parent_id]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_ARGUMENTS',
        message: 'File ID and new parent ID required'
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end
    manager.move_file(
      file_id: options[:file_id],
      new_parent_id: options[:new_parent_id]
    )

  when 'delete'
    unless options[:file_id]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_FILE_ID',
        message: 'File ID required'
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end
    manager.delete_file(
      file_id: options[:file_id],
      permanent: options[:permanent] || false
    )

  when 'share'
    unless options[:file_id] && options[:role]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_ARGUMENTS',
        message: 'File ID and role required'
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end
    manager.share_file(
      file_id: options[:file_id],
      email: options[:email],
      role: options[:role],
      type: options[:type] || 'user'
    )

  when 'permissions'
    unless options[:file_id]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_FILE_ID',
        message: 'File ID required'
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end
    manager.list_permissions(file_id: options[:file_id])

  when 'remove-permission'
    unless options[:file_id] && options[:permission_id]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_ARGUMENTS',
        message: 'File ID and permission ID required'
      })
      exit DriveManager::EXIT_INVALID_ARGS
    end
    manager.remove_permission(
      file_id: options[:file_id],
      permission_id: options[:permission_id]
    )

  else
    puts JSON.pretty_generate({
      status: 'error',
      error_code: 'INVALID_COMMAND',
      message: "Unknown command: #{command}"
    })
    usage
    exit DriveManager::EXIT_INVALID_ARGS
  end

  exit DriveManager::EXIT_SUCCESS
end
