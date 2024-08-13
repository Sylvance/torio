# frozen_string_literal: true

# ExampleClient
class ExampleClient
  include ApplicationClient

  def self.config_definition
    ExampleClientConfig
  end

  def self.result_codes
    {
      'SUCCESS' => :success,
      'PENDING' => :pending,
      'ERROR'   => :error,
      'NOT_FOUND' => :not_found
    }
  end

  def self.failure_codes
    {
      timeout: :request_timeout,
      authentication_failed: :auth_error,
      unknown_failure: :unknown_error
    }
  end

  private

  def perform_request
    # Example logic for performing the request.
    response = execute_api_call

    case response.status_code
    when 200
      'SUCCESS'
    when 404
      'NOT_FOUND'
    when 500
      'ERROR'
    else
      'UNKNOWN'
    end
  rescue Timeout::Error
    raise StandardError, 'timeout'
  rescue AuthenticationError
    raise StandardError, 'authentication_failed'
  end

  def execute_api_call
    # Simulated API call logic
    OpenStruct.new(status_code: 404)
    raise Timeout::Error
  end
end
