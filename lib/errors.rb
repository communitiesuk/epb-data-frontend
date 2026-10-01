# frozen_string_literal: true

module Errors
  class ApiError < RuntimeError
  end

  class NonJsonResponseError < ApiError
  end

  class ApiAuthorizationError < ApiError
  end

  class MalformedErrorResponseError < ApiError
  end

  class ConnectionApiError < ApiError
  end

  class RequestTimeoutError < ConnectionApiError
  end

  class ResponseNotPresentError < ApiError
  end

  class InternalServerError < ApiError
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

  class InvalidArgument < RuntimeError
  end

  class FileNotFound < RuntimeError
  end

  class FilteredDataNotFound < RuntimeError
  end

  class OneloginSigningError < RuntimeError
  end

  class AuthenticationError < RuntimeError
  end

  class ValidationError < RuntimeError
  end

  class StateMismatch < AuthenticationError
  end

  class AccessDeniedError < AuthenticationError
  end

  class LoginRequiredError < AuthenticationError
  end

  class InvalidGrantError < AuthenticationError
  end

  class TokenExchangeError < ApiError
  end

  class UserEmailNotVerified < RuntimeError
  end

  class NetworkError < ApiError
  end

  class BearerTokenMissing < RuntimeError
  end

  class UserMissing < RuntimeError
  end

  class MissingOptOutValues < RuntimeError
  end

  class MissingDownloadCount < RuntimeError
  end

  class NotifySendEmailError < RuntimeError
  end

  class NotifyServerError < RuntimeError
  end

  class KmsEncryptionError < RuntimeError
  end

  class KmsDecryptionError < RuntimeError
  end

  class SessionEmailError < RuntimeError
  end

  class MissingReferrerError < RuntimeError
  end

  module DoNotReport
  end
end
