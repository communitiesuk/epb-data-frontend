# frozen_string_literal: true

module Errors
  class AuthTokenMissing < RuntimeError
  end

  class ApiError < RuntimeError
  end

  class ConfigurationError < RuntimeError
  end

  class NonJsonResponseError < ApiError
  end

  class ApiAuthorizationError < ApiError
  end

  class MalformedErrorResponseError < ApiError
  end

  class UnknownErrorResponseError < ApiError
  end

  class ConnectionApiError < ApiError
  end

  class RequestTimeoutError < ConnectionApiError
  end

  class ResponseNotPresentError < ApiError
  end

  class InternalServerError < ApiError
  end

  class BotDetected < RuntimeError
  end

  class PostcodeNotValid < RuntimeError
  end

  class PostcodeWrongFormat < RuntimeError
  end

  class PostcodeIncomplete < RuntimeError
  end

  class InvalidPropertyType < RuntimeError
  end

  class InvalidDateArgument < RuntimeError
  end

  class FileNotFound < RuntimeError
  end

  class FilteredDataNotFound < RuntimeError
  end

  class MissingEnvVariable < RuntimeError
    def initialize(env_variable)
      @env_variable = env_variable
      super("Environment variable '#{env_variable}' is missing.")
    end
  end

  class OneloginSigningError < RuntimeError
  end

  class AuthenticationError < RuntimeError
    def initialize(message)
      @message = message
      super(message)
    end
  end

  class StateMismatch < AuthenticationError
  end

  class AccessDeniedError < AuthenticationError
  end

  class LoginRequiredError < AuthenticationError
  end

  module DoNotReport
  end
end
