#!/usr/bin/env ruby
# frozen_string_literal: true

require 'google/apis/sheets_v4'
require 'google/apis/drive_v3'
require 'google/apis/docs_v1'
require 'google/apis/calendar_v3'
require 'google/apis/people_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'json'

# Sheets Manager - Google CLI Integration for Spreadsheet Operations
# Version: 1.0.0
# Scopes: Sheets, Drive, Docs, Calendar, Contacts, Gmail (shared token)
class SheetsManager
  SHEETS_SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS
  DRIVE_SCOPE = Google::Apis::DriveV3::AUTH_DRIVE
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
    @service = Google::Apis::SheetsV4::SheetsService.new
    @service.client_options.application_name = 'Claude Sheets Skill'
    @service.authorization = authorize
  end

  # Authorize using shared OAuth token with all Google skills scopes
  def authorize
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)

    # Include ALL scopes for shared token across Google skills
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
          '2. Grant access to all Google services',
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
      scopes: [SHEETS_SCOPE, DRIVE_SCOPE, DOCS_SCOPE, CALENDAR_SCOPE, CONTACTS_SCOPE, GMAIL_SCOPE]
    })
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'AUTH_FAILED',
      message: "Authorization failed: #{e.message}"
    })
    exit EXIT_AUTH_ERROR
  end

  # Read cell values from spreadsheet
  def read_values(spreadsheet_id:, range:)
    result = @service.get_spreadsheet_values(spreadsheet_id, range)

    output_json({
      status: 'success',
      operation: 'read',
      spreadsheet_id: spreadsheet_id,
      range: range,
      values: result.values || [],
      row_count: result.values&.length || 0
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'read',
      message: "Sheets API error: #{e.message}",
      details: e.body
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'READ_FAILED',
      operation: 'read',
      message: "Failed to read values: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Write cell values to spreadsheet
  def write_values(spreadsheet_id:, range:, values:, input_option: 'USER_ENTERED')
    value_range = Google::Apis::SheetsV4::ValueRange.new(values: values)

    result = @service.update_spreadsheet_value(
      spreadsheet_id,
      range,
      value_range,
      value_input_option: input_option
    )

    output_json({
      status: 'success',
      operation: 'write',
      spreadsheet_id: spreadsheet_id,
      range: range,
      updated_cells: result.updated_cells,
      updated_rows: result.updated_rows,
      updated_columns: result.updated_columns
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'write',
      message: "Sheets API error: #{e.message}",
      details: e.body
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'WRITE_FAILED',
      operation: 'write',
      message: "Failed to write values: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Append rows to spreadsheet
  def append_values(spreadsheet_id:, range:, values:, input_option: 'USER_ENTERED')
    value_range = Google::Apis::SheetsV4::ValueRange.new(values: values)

    result = @service.append_spreadsheet_value(
      spreadsheet_id,
      range,
      value_range,
      value_input_option: input_option
    )

    output_json({
      status: 'success',
      operation: 'append',
      spreadsheet_id: spreadsheet_id,
      range: result.table_range,
      updated_cells: result.updates.updated_cells,
      updated_rows: result.updates.updated_rows
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'append',
      message: "Sheets API error: #{e.message}",
      details: e.body
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'APPEND_FAILED',
      operation: 'append',
      message: "Failed to append values: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Clear cell values
  def clear_values(spreadsheet_id:, range:)
    clear_request = Google::Apis::SheetsV4::ClearValuesRequest.new

    result = @service.clear_values(spreadsheet_id, range, clear_request)

    output_json({
      status: 'success',
      operation: 'clear',
      spreadsheet_id: spreadsheet_id,
      range: result.cleared_range
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'clear',
      message: "Sheets API error: #{e.message}",
      details: e.body
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'CLEAR_FAILED',
      operation: 'clear',
      message: "Failed to clear values: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Get spreadsheet metadata
  def get_metadata(spreadsheet_id:)
    result = @service.get_spreadsheet(spreadsheet_id)

    sheets = result.sheets.map do |sheet|
      {
        sheet_id: sheet.properties.sheet_id,
        title: sheet.properties.title,
        index: sheet.properties.index,
        row_count: sheet.properties.grid_properties&.row_count,
        column_count: sheet.properties.grid_properties&.column_count
      }
    end

    output_json({
      status: 'success',
      operation: 'metadata',
      spreadsheet_id: result.spreadsheet_id,
      title: result.properties.title,
      locale: result.properties.locale,
      timezone: result.properties.time_zone,
      sheets: sheets
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'metadata',
      message: "Sheets API error: #{e.message}",
      details: e.body
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'METADATA_FAILED',
      operation: 'metadata',
      message: "Failed to get metadata: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Create new sheet within spreadsheet
  def create_sheet(spreadsheet_id:, title:, row_count: 1000, column_count: 26)
    request = Google::Apis::SheetsV4::Request.new(
      add_sheet: Google::Apis::SheetsV4::AddSheetRequest.new(
        properties: Google::Apis::SheetsV4::SheetProperties.new(
          title: title,
          grid_properties: Google::Apis::SheetsV4::GridProperties.new(
            row_count: row_count,
            column_count: column_count
          )
        )
      )
    )

    batch_request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(
      requests: [request]
    )

    result = @service.batch_update_spreadsheet(spreadsheet_id, batch_request)
    sheet_properties = result.replies.first.add_sheet.properties

    output_json({
      status: 'success',
      operation: 'create_sheet',
      spreadsheet_id: spreadsheet_id,
      sheet_id: sheet_properties.sheet_id,
      title: sheet_properties.title,
      row_count: sheet_properties.grid_properties.row_count,
      column_count: sheet_properties.grid_properties.column_count
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'create_sheet',
      message: "Sheets API error: #{e.message}",
      details: e.body
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'CREATE_SHEET_FAILED',
      operation: 'create_sheet',
      message: "Failed to create sheet: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Update cell formatting (basic)
  def update_format(spreadsheet_id:, sheet_id:, start_row:, end_row:, start_col:, end_col:, format:)
    # Parse format JSON
    cell_format = Google::Apis::SheetsV4::CellFormat.new

    if format['bold'] || format['italic'] || format['fontSize']
      text_format = Google::Apis::SheetsV4::TextFormat.new
      text_format.bold = format['bold'] if format['bold']
      text_format.italic = format['italic'] if format['italic']
      text_format.font_size = format['fontSize'] if format['fontSize']
      cell_format.text_format = text_format
    end

    if format['backgroundColor']
      bg = format['backgroundColor']
      cell_format.background_color = Google::Apis::SheetsV4::Color.new(
        red: bg['red'] || 0,
        green: bg['green'] || 0,
        blue: bg['blue'] || 0,
        alpha: bg['alpha'] || 1
      )
    end

    request = Google::Apis::SheetsV4::Request.new(
      repeat_cell: Google::Apis::SheetsV4::RepeatCellRequest.new(
        range: Google::Apis::SheetsV4::GridRange.new(
          sheet_id: sheet_id,
          start_row_index: start_row,
          end_row_index: end_row,
          start_column_index: start_col,
          end_column_index: end_col
        ),
        cell: Google::Apis::SheetsV4::CellData.new(user_entered_format: cell_format),
        fields: 'userEnteredFormat(backgroundColor,textFormat)'
      )
    )

    batch_request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(
      requests: [request]
    )

    @service.batch_update_spreadsheet(spreadsheet_id, batch_request)

    output_json({
      status: 'success',
      operation: 'format',
      spreadsheet_id: spreadsheet_id,
      sheet_id: sheet_id,
      formatted_range: "R#{start_row}C#{start_col}:R#{end_row}C#{end_col}"
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'format',
      message: "Sheets API error: #{e.message}",
      details: e.body
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'FORMAT_FAILED',
      operation: 'format',
      message: "Failed to update format: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Batch update operations (multiple writes)
  def batch_update(spreadsheet_id:, updates:)
    data = updates.map do |update|
      Google::Apis::SheetsV4::ValueRange.new(
        range: update['range'],
        values: update['values']
      )
    end

    batch_request = Google::Apis::SheetsV4::BatchUpdateValuesRequest.new(
      data: data,
      value_input_option: 'USER_ENTERED'
    )

    result = @service.batch_update_values(spreadsheet_id, batch_request)

    output_json({
      status: 'success',
      operation: 'batch_update',
      spreadsheet_id: spreadsheet_id,
      total_updated_cells: result.total_updated_cells,
      total_updated_rows: result.total_updated_rows,
      responses: result.responses.length
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'batch_update',
      message: "Sheets API error: #{e.message}",
      details: e.body
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'BATCH_UPDATE_FAILED',
      operation: 'batch_update',
      message: "Failed to batch update: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  private

  # Output JSON to stdout
  def output_json(data)
    puts JSON.pretty_generate(data)
  end
end

# CLI Interface
def usage
  puts <<~USAGE
    Sheets Manager - Google CLI Integration for Spreadsheet Operations
    Version: 1.0.0

    Usage:
      #{File.basename($PROGRAM_NAME)} <command> [options]

    Commands:
      auth <code>           Complete OAuth authorization with code
      read                  Read cell values
      write                 Write cell values
      append                Append rows to sheet
      clear                 Clear cell values
      metadata              Get spreadsheet metadata
      create_sheet          Create new sheet within spreadsheet
      format                Update cell formatting
      batch_update          Batch update multiple ranges

    Read Options (JSON via stdin):
      {
        "spreadsheet_id": "abc123xyz",
        "range": "Sheet1!A1:B10"
      }

    Write Options (JSON via stdin):
      {
        "spreadsheet_id": "abc123xyz",
        "range": "Sheet1!A1:B2",
        "values": [["Row1Col1", "Row1Col2"], ["Row2Col1", "Row2Col2"]],
        "input_option": "USER_ENTERED"  # Optional: USER_ENTERED (default) or RAW
      }

    Append Options (JSON via stdin):
      {
        "spreadsheet_id": "abc123xyz",
        "range": "Sheet1!A1",
        "values": [["New", "Row"], ["Another", "Row"]]
      }

    Clear Options (JSON via stdin):
      {
        "spreadsheet_id": "abc123xyz",
        "range": "Sheet1!A1:Z100"
      }

    Metadata Options (JSON via stdin):
      {
        "spreadsheet_id": "abc123xyz"
      }

    Create Sheet Options (JSON via stdin):
      {
        "spreadsheet_id": "abc123xyz",
        "title": "New Sheet Name",
        "row_count": 1000,      # Optional, default 1000
        "column_count": 26      # Optional, default 26
      }

    Format Options (JSON via stdin):
      {
        "spreadsheet_id": "abc123xyz",
        "sheet_id": 0,
        "start_row": 0,
        "end_row": 1,
        "start_col": 0,
        "end_col": 5,
        "format": {
          "bold": true,
          "italic": false,
          "fontSize": 12,
          "backgroundColor": {"red": 0.9, "green": 0.9, "blue": 0.9, "alpha": 1}
        }
      }

    Batch Update Options (JSON via stdin):
      {
        "spreadsheet_id": "abc123xyz",
        "updates": [
          {"range": "Sheet1!A1:A2", "values": [["Value1"], ["Value2"]]},
          {"range": "Sheet1!B1:B2", "values": [["Value3"], ["Value4"]]}
        ]
      }

    Examples:
      # Complete OAuth authorization
      #{File.basename($PROGRAM_NAME)} auth YOUR_AUTH_CODE

      # Read cell values
      echo '{"spreadsheet_id":"abc123","range":"Sheet1!A1:B10"}' | #{File.basename($PROGRAM_NAME)} read

      # Write cell values
      echo '{"spreadsheet_id":"abc123","range":"Sheet1!A1:B2","values":[["A1","B1"],["A2","B2"]]}' | #{File.basename($PROGRAM_NAME)} write

      # Append rows
      echo '{"spreadsheet_id":"abc123","range":"Sheet1!A1","values":[["New","Row"]]}' | #{File.basename($PROGRAM_NAME)} append

      # Clear range
      echo '{"spreadsheet_id":"abc123","range":"Sheet1!A1:Z100"}' | #{File.basename($PROGRAM_NAME)} clear

      # Get metadata
      echo '{"spreadsheet_id":"abc123"}' | #{File.basename($PROGRAM_NAME)} metadata

    Exit Codes:
      0 - Success
      1 - Operation failed
      2 - Authentication error
      3 - API error
      4 - Invalid arguments

    A1 Notation:
      - Single cell: A1, B5, Z10
      - Range: A1:B10, C5:F20
      - Entire row: 1:1, 5:10
      - Entire column: A:A, C:E
      - Named sheet: Sheet1!A1:B10
  USAGE
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    usage
    exit SheetsManager::EXIT_INVALID_ARGS
  end

  command = ARGV[0]

  # Handle auth command separately (doesn't require initialized service)
  if command == 'auth'
    if ARGV.length < 2
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_CODE',
        message: 'Authorization code required',
        usage: "#{File.basename($PROGRAM_NAME)} auth <code>"
      })
      exit SheetsManager::EXIT_INVALID_ARGS
    end

    # Create temporary manager just for auth completion
    temp_manager = SheetsManager.allocate
    temp_manager.complete_auth(ARGV[1])
    exit SheetsManager::EXIT_SUCCESS
  end

  # For all other commands, create manager (which requires authorization)
  manager = SheetsManager.new

  case command

  when 'read'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:spreadsheet_id] && input[:range]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: spreadsheet_id, range'
      })
      exit SheetsManager::EXIT_INVALID_ARGS
    end

    manager.read_values(
      spreadsheet_id: input[:spreadsheet_id],
      range: input[:range]
    )

  when 'write'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:spreadsheet_id] && input[:range] && input[:values]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: spreadsheet_id, range, values'
      })
      exit SheetsManager::EXIT_INVALID_ARGS
    end

    manager.write_values(
      spreadsheet_id: input[:spreadsheet_id],
      range: input[:range],
      values: input[:values],
      input_option: input[:input_option] || 'USER_ENTERED'
    )

  when 'append'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:spreadsheet_id] && input[:range] && input[:values]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: spreadsheet_id, range, values'
      })
      exit SheetsManager::EXIT_INVALID_ARGS
    end

    manager.append_values(
      spreadsheet_id: input[:spreadsheet_id],
      range: input[:range],
      values: input[:values],
      input_option: input[:input_option] || 'USER_ENTERED'
    )

  when 'clear'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:spreadsheet_id] && input[:range]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: spreadsheet_id, range'
      })
      exit SheetsManager::EXIT_INVALID_ARGS
    end

    manager.clear_values(
      spreadsheet_id: input[:spreadsheet_id],
      range: input[:range]
    )

  when 'metadata'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:spreadsheet_id]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: spreadsheet_id'
      })
      exit SheetsManager::EXIT_INVALID_ARGS
    end

    manager.get_metadata(spreadsheet_id: input[:spreadsheet_id])

  when 'create_sheet'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:spreadsheet_id] && input[:title]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: spreadsheet_id, title'
      })
      exit SheetsManager::EXIT_INVALID_ARGS
    end

    manager.create_sheet(
      spreadsheet_id: input[:spreadsheet_id],
      title: input[:title],
      row_count: input[:row_count] || 1000,
      column_count: input[:column_count] || 26
    )

  when 'format'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:spreadsheet_id] && input[:sheet_id] && input[:format]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: spreadsheet_id, sheet_id, start_row, end_row, start_col, end_col, format'
      })
      exit SheetsManager::EXIT_INVALID_ARGS
    end

    manager.update_format(
      spreadsheet_id: input[:spreadsheet_id],
      sheet_id: input[:sheet_id],
      start_row: input[:start_row],
      end_row: input[:end_row],
      start_col: input[:start_col],
      end_col: input[:end_col],
      format: input[:format]
    )

  when 'batch_update'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:spreadsheet_id] && input[:updates]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: spreadsheet_id, updates'
      })
      exit SheetsManager::EXIT_INVALID_ARGS
    end

    manager.batch_update(
      spreadsheet_id: input[:spreadsheet_id],
      updates: input[:updates]
    )

  else
    puts JSON.pretty_generate({
      status: 'error',
      error_code: 'INVALID_COMMAND',
      message: "Unknown command: #{command}",
      valid_commands: ['auth', 'read', 'write', 'append', 'clear', 'metadata', 'create_sheet', 'format', 'batch_update']
    })
    usage
    exit SheetsManager::EXIT_INVALID_ARGS
  end

  exit SheetsManager::EXIT_SUCCESS
end
