.PHONY: all
default: build-dev

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'

build: ## builds and install env
	if [ ! -f .env ]; then cp .env.dist .env; fi
	docker-compose up -d
	cli/composer install -f --no-dev -n
	make migrate

build-dev: ## builds and install env for development
	if [ ! -f .env ]; then cp .env.dist .env; fi
	docker-compose up -d --build
	cli/composer install --dev -n
	make migrate

VERSION=latest
migrate: ## run migrations
	cli/migrations migrate --no-interaction $(VERSION)

new-migration: ## create a new migration
	cli/migrations generate

doctrine-diff: ## create a migration with de diff
	cli/migrations diff

GET_GIT=-s
check-lint: php-syntax phpstan phpcs php-cs-fixer-check ## run lints over stagged changes

check: GET_GIT=-d
check: check-lint tests ## run check-lint for changed files and tests

check-all: GET_GIT=-a
check-all: check-lint tests ## run check-lint for all files and tests

tests: ## run unit tests (phpunit)
	cli/run-local cli/unit-tests

php-syntax: ## check syntax
	cli/run-local cli/php-syntax $(GET_GIT)

phpstan: ## runs phpstan
	cli/run-local cli/phpstan $(GET_GIT)

phpcs: ## runs phpcs
	cli/run-local cli/phpcs $(GET_GIT)

phpcbf: ## runs phpcbf for auto-fixes
	cli/run-local --as-myself cli/phpcbf $(GET_GIT) || true

php-cs-fixer: ## runs php-cs-fixer for auto-fixes
	cli/run-local --as-myself cli/php-cs-fixer $(GET_GIT) || true

auto-fix-diff: GET_GIT=-d
auto-fix-diff: phpcbf php-cs-fixer ## run all auto-fixers for changed files

php-cs-fixer-check: ## runs php-cs-fixer for checks
	cli/run-local cli/php-cs-fixer $(GET_GIT) --dry-run
