.PHONY: tests
default: build-dev

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'

build: ## builds and install env
	if [ ! -f .env ]; then cp .env.dist .env; fi
	docker-compose up -d
	server/cli/composer install -f --no-dev -n

build-dev: ## builds and install env for development
	if [ ! -f .env ]; then cp .env.dist .env; fi
	docker-compose up -d --build
	server/cli/composer install --dev -n
