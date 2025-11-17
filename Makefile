.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: frontend-build
frontend-build: ## Run the frontend build process to compile sass and move asset files to public
	@echo "Building frontend assets..."
	ruby ./build/compile_assets.rb

frontend-build-watch:
	@$(SHELL) ./scripts/frontend-build-watch.sh

.PHONY: test
test:
	@bundle exec rspec

.PHONY: hosts
hosts:
	@scripts/configure-tests-hosts.sh

.PHONY: assets-version
assets-version:
	@scripts/write-assets-version.sh

.PHONY: run
run:
	@bundle exec rackup -p 9292 ${ARGS}

.PHONY: formatmak
format:
	@bundle exec rubocop --autocorrect || true

.PHONY: journey
journey:
	@bundle exec rspec --tag journey


.PHONY: one-login
one-login:
	@scripts/one_login_simulator.sh

.PHONY: reload-local
reload-local:
	@make frontend-build
	@make run ARGS=config_test.ru
