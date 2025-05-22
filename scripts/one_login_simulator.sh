#!/bin/bash

docker stop one-login-simulator

docker run -e SIMULATOR_URL='http://localhost:3333' --rm --detach \
    -e PORT=3333 \
    -e PUBLIC_KEY="-----BEGIN PUBLIC KEY----- MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArGvxQU80uOxKzlmbCHNOkjcgTF415lSHTmbr3x8jFEHvXu+NzXD0qHMIIQ217foYJAwT/RdTpaaeOW7sXdIqgAUhQwCNhSyuTx0sIMM0G0YXHOmLXAiRzwApLBxKYYU4i66T6ACP7Io0pDEqHu0sFrfdnfV+3JaaRlWkGXpKarwMtMAhzSdE5UGgxJ08d7qLJ/g8lbQZxcrVmyLragmYHEfzgAYyv8WFKEj2n0rcFzntcjZXy9EZOxlFqMn27Vr/lz+Yye2zio4+j/d8S8Q6V1oddVHwMAB8rG+CaTJg+63Z61dtStYMxIl2CFBld4UpWTkWrGdmHnKkYZeZRnrm7QIDAQAB -----END PUBLIC KEY-----" \
    -e SCOPES="openid,email" \
    -e REDIRECT_URLS="http://127.0.0.1:9292/login/callback" \
    --name one-login-simulator -p 3333:3333 ghcr.io/govuk-one-login/simulator:latest

