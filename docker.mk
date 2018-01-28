help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "\033[36m%-22s\033[0m %s\n", $$1, $$NF }' $(MAKEFILE_LIST)

.PHONY: up down ps rmi logs build

DOCKER_COMPOSE	:= docker-compose -f docker-compose.yml --no-ansi
IMAGE_NAME	:= yamlssm-sample

### docker
build: ## Docker build
	@docker build . -t $(IMAGE_NAME):latest
	@docker build ./docker/mysql -t $(IMAGE_NAME)_mysql:latest

rmi: down##Docker rmi
	@docker rmi -f $(IMAGE_NAME):latest
	@docker rmi -f $(IMAGE_NAME)_mysql:latest

up: ## compose立ち上げ
	@$(DOCKER_COMPOSE) up -d

down: ## composeのコンテナ削除
	-@$(DOCKER_COMPOSE) down

ps: ## composeの状態表示
	@$(DOCKER_COMPOSE) ps

logs: ## composeの状態表示
	@$(DOCKER_COMPOSE) logs -f
