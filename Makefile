# ==============================================================================
# Main

run:
	go run ./cmd/email_service/main.go

build:
	go build ./cmd/email_service/main.go

test:
	go test -cover ./...


# ==============================================================================
# Modules support

deps-reset:
	git checkout -- go.mod
	go mod tidy
	go mod vendor

tidy:
	go mod tidy
	go mod vendor

deps-upgrade:
	# go get $(go list -f '{{if not (or .Main .Indirect)}}{{.Path}}{{end}}' -m all)
	go get -u -t -d -v ./...
	go mod tidy
	go mod vendor

deps-cleancache:
	go clean -modcache

# ==============================================================================
# Tools commands

run-linter:
	echo "Starting linters"
	golangci-lint run ./...

run-lint-with-output:
	echo "Starting linters creating output file"
	golangci-lint run --out-format json >> output.json ./...

# ==============================================================================
# Go migrate postgresql

DB_NAME = mails_db

force:
	migrate -database postgres://postgres:postgres@localhost:5432/$(DB_NAME)?sslmode=disable -path migrations force 1

version:
	migrate -database postgres://postgres:postgres@localhost:5432/$(DB_NAME)?sslmode=disable -path migrations version

migrate_up:
	migrate -database postgres://postgres:postgres@localhost:5432/$(DB_NAME)?sslmode=disable -path migrations up 1

migrate_down:
	migrate -database postgres://postgres:postgres@localhost:5432/$(DB_NAME)?sslmode=disable -path migrations down 1


# ==============================================================================
# Docker compose commands

develop:
	echo "Starting docker environment"
	docker-compose -f docker-compose.yml up -d --build

local:
	echo "Starting local environment"
	docker-compose -f docker-compose.local.yml up -d --build

local-compose-logs:
	echo "Getting local docker compose logs"
	docker-compose -f docker-compose.local.yml logs

develop-compose-logs:
	echo "Getting develop docker compose logs"
	docker-compose -f docker-compose.yml logs

local-compose-ps:
	echo "Getting local docker compose ps"
	docker-compose -f docker-compose.local.yml ps

develop-compose-ps:
	echo "Getting develop docker compose ps"
	docker-compose -f docker-compose.yml ps

develop-down:
	echo "Starting docker environment"
	docker-compose -f docker-compose.yml down

local-down:
	echo "Starting local environment"
	docker-compose -f docker-compose.local.yml down

# ==============================================================================
# Docker support

FILES := $(shell docker ps -aq)

down-local:
	docker stop $(FILES)
	docker rm $(FILES)

clean:
	docker system prune -f

logs-local:
	docker logs -f $(FILES)