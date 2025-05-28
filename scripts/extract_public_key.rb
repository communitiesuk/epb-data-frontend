require 'json'
require_relative '../spec/test_doubles/one_login_stub'

puts JSON.parse(OneLoginStub.tls_keys)["public_key"]
