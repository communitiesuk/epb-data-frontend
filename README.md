# Energy Performance Certificate Data

Frontend for the Energy Performance Certificate Data

## Getting Started

Make sure you have the following installed:

- [Ruby](https://www.ruby-lang.org)
  - [Bundler](https://bundler.io) to install dependencies found in `Gemfile`
- [Git](https://git-scm.com) (_optional_)

### Install

This short guide will use `Git`.

1. Clone the repository: `$ git clone git@github.com:communitiesuk/epb-data-frontend.git`
2. Change into the cloned repository: `$ cd epb-data-frontend`
3. Install the Ruby gems:
   - `$ rvm use`
   - `$ bundle install`
4. Install node packages:
   - `$ nvm use`
   - `$ npm install`
5. Build the frontend assets: `$ make frontend-build`

## Test

### Prerequisites

You must add additional local hosts to your hosts file on your machine with:

```
127.0.0.1	get-energy-performance-data.epb-frontend
127.0.0.1	get-energy-performance-data.local.gov.uk
```

You can add these to your hosts file automatically by running `$ sudo make hosts`.
You can check what hosts you already have by typing `$ cat /etc/hosts` in the
frontend directory.

Don't forget to ensure bundles are up to date

### Test suites

To run the respective test suites:

- All tests: `$ make test`

## Usage

### Running the frontend

#### The test stubs server

1. To run the test stubs server (i.e. the frontend in isolation from the local API),
   change directory into the root of the cloned folder: `$ cd epb-data-frontend`
2. Start the web server(s) using the following command: `$ make run ARGS=config_test.ru`
3. Open <http://get-energy-performance-data.epb-frontend:9393> in your favourite browser to
   run the test server with htpp.

#### The integrated server

1. To run the local frontend alongside your local API in Docker, make sure that
   the Docker images from the epb-dev-tools repo are running
2. Then access the frontend at <http://get-energy-performance-data.epb-frontend> (without the specified ports).

#### Running with One Login Simulator

The site uses GOV.UK One Login to manage user access.</br>
To test this on your local host you will need to run One Login Simulator, this will mimic the authorization process and allow user access to continue.

1. The run the One Login Simulator `$ make one-login`
2. To see the configuration of the One Login Simulator `$ curl localhost:3333/config`

This allows the simulator to authorize requests from http://127.0.0.1/9292 and send the callback response to the same domain.

## Environmental variables

#### `APP_ENV`

Set the [Sintra environment](https://sinatrarb.com/intro.html#environments).
Should be one of "production", "development" or "test".

Sinatra will fallback to `RACK_ENV` or "development" if unset.

#### `RACK_ENV`

Used by rackup to choose the [default middleware stack](https://github.com/rack/rackup/blob/f3fa1d6ada90e9e7aa1f712488ddde87ea2a2075/lib/rackup/server.rb#L273).
Should be one of "development" (default) or "deployment". If set to any other value no middleware stack is loaded.

#### `STAGE`

The EPB environment. Can be one of "test", "development", "integration", "staging" or "production".

- Sets the unleash feature flag service app name to `toggles-#{stage}`
- Selects the gov.uk one login sign-in page for CSP form action
- When "test", configures exceptions and enabled Capybara lock-step
- Unless "development" or "test", enables Sentry and sets its environment value
- Unless "production", sets the tag used in the phase banner
- When "production", replaces the phase banner with the feedback banner
- When "production", disables the test service message in notify opt-out emails

#### `LOCAL_SESSION`

If set to `true` the session cookie will be set to `same-site: lax`, and not `secure`.
This is also the case if the Sinatra environment is `development`.

#### `ASSETS_VERSION`

The value of the cache busting prefix used for serving assets.

This is a random number generated for each production build by `make assets-version` and saved to an `./ASSETS_VERSION` file.

Do not set this for local development.

#### `SCRIPT_NONCE`

The nonce used by the Content-Security-Policy to protect against XSS attacks.

#### `SESSION_SECRET`

The secret uses to sign the session cookie and prevent cookie tampering.

#### `enable-csrf`

Enables the `Rack::Protection::RemoteReferrer` and `Rack::Protection::AuthenticityToken` modules.
This is always enabled except in "test".

#### `AWS_S3_USER_DATA_BUCKET_NAME`

The AWS S3 bucket containing the generated CSVs for user download.

#### `SEND_DOWNLOAD_TOPIC_ARN`

AWS SNS topic for requests to generate CSV data/.

#### `EPB_DATA_USER_CREDENTIAL_TABLE_NAME`

The name of the dynamo db table used to store user accounts.

#### `KMS_KEY_ID`

The id of the encryption key used to encrypt user emails in the dynamo database user table.

#### `AWS_KMS_ENDPOINT`

In development, sets the endpoint for the AWS Key Management Service.

#### `AWS_ACCESS_KEY_ID`

In development, sets the access key id used to access the AWS Key Management Service.

#### `AWS_SECRET_ACCESS_KEY`

In development, sets the secret access key used to access the AWS Key Management Service.

#### `AWS_REGION`

The region for AWS services. Only explicit set in tests.

#### `EPB_AUTH_CLIENT_ID`

The client id for connecting to the data-warehouse API.

#### `EPB_AUTH_CLIENT_SECRET`

The client secret for connecting to the data-warehouse API.

#### `EPB_AUTH_SERVER`

The URL of the auth server for connecting to the data-warehouse API.

#### `EPB_DATA_WAREHOUSE_API_URL`

The URL of the data-warehouse API.

#### `EPB_RECAPTCHA_SITE_KEY`

The key for the Google Recaptcha service.

_Not used_

#### `EPB_RECAPTCHA_SITE_SECRET`

The secret for the Google Recaptcha service.

_Not used_

#### `EPB_SUSPECTED_BOT_USER_AGENTS`

A JSON formatted array of strings containing a list of user-agent strings that should be presented with a recaptcha.

_Not used_

#### `EPB_UNLEASH_URI`

The URL of the unleash feature flag service.

#### `GTM_PROPERTY_FINDING`

The Google tag manager container id used to load Google Analytics.

#### `NOTIFY_DATA_API_KEY`

The API for the gov.uk notify service.

#### `NOTIFY_DATA_EMAIL_RECIPIENT`

_Not used_

#### `NOTIFY_OPT_OUT_EMAIL_RECIPIENT`

The email address opt-out requests should be sent to.

#### `NOTIFY_OPT_OUT_TEMPLATE_ID`

The id of the gov.uk notify service template for opt-out emails.

#### `ONELOGIN_CLIENT_ID`

The client id for the gov.uk One Login service.

#### `ONELOGIN_HOST_URL`

The URL of the gov.uk One Login service.

#### `ONELOGIN_TLS_KEYS`

The cryptographic key used to sign authorization requests to the gov.uk One Login service.

A JSON formatted object with the following keys:

- kid
- private_key
- public_key

#### `ALG`

The algorithm used to sign the gov.uk one login authorize requests.

Either "RS256" or "ES256". Must match the setting in the One Login admin tool.

#### `PUBLISHED_DWH_API_URL`

The public URL of the data-warehouse API.
