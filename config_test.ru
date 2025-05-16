# frozen_string_literal: true

require "net/http"
require "zeitwerk"
require "webmock"
require "active_support"
require "webmock/rspec"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.push_dir("#{__dir__}/spec/test_doubles/")
loader.setup

WebMock.enable!

TogglesStub.enable(nil)
OauthStub.token

default_end_date = Date.new(Date.today.year.to_i, Date::MONTHNAMES.index((Date.today << 1).strftime("%B")) || 0, -1).to_s

CertificateCountStub.fetch(date_start: "2012-01-01", date_end: default_end_date)
CertificateCountStub.fetch(date_start: "2024-05-01", date_end: "2025-03-31", council: %w[Adur], return_count: 10)
CertificateCountStub.fetch(date_start: "2024-05-01", date_end: default_end_date, council: %w[Adur Birmingham])
CertificateCountStub.fetch(date_start: "2024-05-01", date_end: default_end_date, constituency: %w[Ashford Barking])
sns_message =
  {
    "email_address" => "test@example.com",
    "property_type" => "domestic",
    "date_start" => "01-01-2021",
    "date_end" => "01-01-2022",
    "area" => {
      "councils" => %w[Aberdeen Angus],
    },
    "efficiency_ratings" => %w[A B C],
  }
SnsClientStub.fetch(message: sns_message)

ENV["STAGE"] = "test"
ENV["EPB_UNLEASH_URI"] = "https://test-toggle-server/api"
ENV["AWS_TEST_ACCESS_ID"] = "test.aws.id"
ENV["AWS_TEST_ACCESS_SECRET"] = "test.aws.secret"
ENV["SEND_DOWNLOAD_TOPIC_ARN"] = "arn:aws:sns:us-east-1:123456789012:testTopic"
AUTH_URL = "http://test-auth-server.gov.uk"
ENV["EPB_AUTH_CLIENT_ID"] = "test.id"
ENV["EPB_AUTH_CLIENT_SECRET"] = "test.client.secret"
ENV["EPB_AUTH_SERVER"] = AUTH_URL
ENV["EPB_DATA_WAREHOUSE_API_URL"] = "http://epb-data-warehouse-api"
ENV["AWS_S3_USER_DATA_BUCKET_NAME"] = "user-data"
ENV["ONELOGIN_HOST_URL"] = "https://oidc.integration.account.gov.uk"
ENV["ONELOGIN_CLIENT_ID"] = "test.onelogin.client.id"
ENV["ONELOGIN_TLS_KEYS"] = {
  kid: "355a5c3d-7a21-4e1e-8ab9-aa14c33d83fb",
  public_key: "-----BEGIN PUBLIC KEY-----\n" \
    "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArGvxQU80uOxKzlmbCHNO\n" \
    "kjcgTF415lSHTmbr3x8jFEHvXu+NzXD0qHMIIQ217foYJAwT/RdTpaaeOW7sXdIq\n" \
    "gAUhQwCNhSyuTx0sIMM0G0YXHOmLXAiRzwApLBxKYYU4i66T6ACP7Io0pDEqHu0s\n" \
    "FrfdnfV+3JaaRlWkGXpKarwMtMAhzSdE5UGgxJ08d7qLJ/g8lbQZxcrVmyLragmY\n" \
    "HEfzgAYyv8WFKEj2n0rcFzntcjZXy9EZOxlFqMn27Vr/lz+Yye2zio4+j/d8S8Q6\n" \
    "V1oddVHwMAB8rG+CaTJg+63Z61dtStYMxIl2CFBld4UpWTkWrGdmHnKkYZeZRnrm\n" \
    "7QIDAQAB\n" \
    "-----END PUBLIC KEY-----",
  private_key: "-----BEGIN PRIVATE KEY-----\n" \
    "MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCsa/FBTzS47ErO\n" \
    "WZsIc06SNyBMXjXmVIdOZuvfHyMUQe9e743NcPSocwghDbXt+hgkDBP9F1Olpp45\n" \
    "buxd0iqABSFDAI2FLK5PHSwgwzQbRhcc6YtcCJHPACksHEphhTiLrpPoAI/sijSk\n" \
    "MSoe7SwWt92d9X7clppGVaQZekpqvAy0wCHNJ0TlQaDEnTx3uosn+DyVtBnFytWb\n" \
    "IutqCZgcR/OABjK/xYUoSPafStwXOe1yNlfL0Rk7GUWoyfbtWv+XP5jJ7bOKjj6P\n" \
    "93xLxDpXWh11UfAwAHysb4JpMmD7rdnrV21K1gzEiXYIUGV3hSlZORasZ2YecqRh\n" \
    "l5lGeubtAgMBAAECggEADBcfmjBHJqZvEmwnGl8Xhdo2uhQrHGUV/dHqvUEOMSf0\n" \
    "dIhAvcSrazpxufufo7nTQofUSP1/QJDf7HASQ/vuPf7eF7gstEdvS53kj8GQYE84\n" \
    "ZK8dtgzlyIme2Xh8YL06O1U5Ct4rOW9xhIfsB7Ii0s7+y8pApJAs7jyoHp88I6LB\n" \
    "ldBKhb6XrLhyqpcyLfHsf1kIP9QDWn2qmsuOVUX9t9WSZZA3txQMBV3xOF0tKuXw\n" \
    "uWG1tj97L14433xa8HP1ljxFRuCth+77V5/kixvoxzxkwjZz01hWgZcTtffnJPbX\n" \
    "70R6AHOublv8My9KgX0ku83LbEK+f7PZn1I0NDX9YwKBgQDbFCiMyAjlmweYUQeq\n" \
    "ZK28iFIIngCFBD0ReZwp+xOur7AO+js+yamQiU5TeiuH98Aj5L2nWLFtF/K6+kyY\n" \
    "eueSKVReIoLy+7j2lKqQUymZdiWoyyJyKyoZV2uRrG+YYl+ntPd67MPNrLvAWUf8\n" \
    "aEHwKILFwlkV21mOodiIkRXTzwKBgQDJetRzZic77TezG1MgFzjm88rhY+WmuKO8\n" \
    "sj5NS2bUZ5doAryJi447dPNOl9QC7SOEyutpdDMBoKmwjPEMSlkFMPvUOp/YgW9Z\n" \
    "t+HfPfYiBwxKoNCmRzsO6aLa0HJkgFl7fQQLKTIInA5MXF1aOd6wNeQtiZcrnC5u\n" \
    "LH7VhmU8gwKBgQCMofYd2VMMwWYwuuNm2FZGzmOKsJK40K27CAvdTxWlb5ZfJvbd\n" \
    "KWs2I04qfCRxlfK7l9y/DkpnM5ZXvNFqmIsK4okMHK9e94QWlfyfxSLRJmyqXCvy\n" \
    "ig7uUZX133GLqqqo55xuRoqy/w1PPoDdYLfjSL4Z4NZ7F2H4E6ECmdAfNQKBgEEv\n" \
    "8JT1tDP7aE4WxSpY2RxAPJ/4BlGO48slkGrJvpdyfNY2LHIEKRyrlh0TmpDn0Noi\n" \
    "HVCdO/OG2+A3ebYUSAEZ/CCKZzVRi4lnqTjlf0E7LormxRtHaKBGj15kmt5ReKIv\n" \
    "rKM/zORkOWwTZlDO8HHqvczN+48slQkodFD5jr+pAoGAIsur/uBMqeedwjCMRQcD\n" \
    "9qvQg6QaWtBvuEkvP2winHbZLfZX/Yd1KJLr4lZqG1ZS1MdDoLN6RBF46t+F90B5\n" \
    "BmRZnic0hWcJiz5Rr9118wRxbblOleG11jEdkmGtLC8GB4LiQESukx58F/Wu6gj7\n" \
    "uXOI2l5UQWPY8/SfrLd4nEg=\n" \
    "-----END PRIVATE KEY-----",
}.to_json

run FrontendService.new
