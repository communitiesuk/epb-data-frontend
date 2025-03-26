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

  module DoNotReport
  end
end
