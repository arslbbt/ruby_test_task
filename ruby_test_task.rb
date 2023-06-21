# frozen_string_literal: true

require 'rest-client'
require 'json'

LOGIN_URL = 'https://discord.com/api/v9/auth/login'
MESSAGES_URL = 'https://discord.com/api/v9/channels/549687005446144041/messages?limit=10'

def authenticate_user(email, password)
	login_payload = {
		login: email,
		password: password,
		undelete: false
	}
  response = RestClient.post(LOGIN_URL, login_payload.to_json, content_type: :json)
  JSON.parse(response.body)['token']
rescue RestClient::ExceptionWithResponse => e
  handle_rest_client_exception(e)
end

def fetch_messages(access_token)
  headers = {
    'Authorization' => access_token,
    'Content-Type' => 'application/json'
  }

  response = RestClient.get(MESSAGES_URL, headers)
  JSON.parse(response.body)
rescue RestClient::ExceptionWithResponse => e
  handle_rest_client_exception(e)
end


def handle_rest_client_exception(exception)
  if exception.response
    response = JSON.parse(exception.response.body)
    error_message = response.dig('errors', 'login', '_errors', 0, 'message')
    if error_message
      puts "Error: #{exception.response.code}"
      puts error_message
    else
      puts "Error: #{exception.response.code}"
      puts "Unexpected response format"
      puts exception.response.body
    end
  else
    puts "Error: #{exception.class}: #{exception.message}"
  end
end

# Main execution flow
begin
	if ARGV.length != 2
		puts "Usage: ruby ruby_test_task.rb <email> <password>"
		exit
	end
	
	email = ARGV[0]
	password = ARGV[1]
  access_token = authenticate_user(email, password)
  messages = fetch_messages(access_token)
	puts JSON.pretty_generate(messages)
end
