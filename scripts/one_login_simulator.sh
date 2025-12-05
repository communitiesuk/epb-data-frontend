#!/bin/bash

PUBLIC_KEY="$(ruby scripts/extract_public_key.rb)"

docker stop one-login-simulator

docker run -e SIMULATOR_URL='http://localhost:3333' --rm --detach \
    -e PORT=3333 \
    -e SCOPES="openid,email" \
    -e CLIENT_ID="test.onelogin.client.id" \
    -e PUBLIC_KEY="$PUBLIC_KEY" \
    -e REDIRECT_URLS="http://127.0.0.1:9292/login/callback,http://127.0.0.1:9292/login/callback/admin,http://127.0.0.1:9292/login/callback/opt-out"\
    --name one-login-simulator -p 3333:3333 ghcr.io/govuk-one-login/simulator:latest

