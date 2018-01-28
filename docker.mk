help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "\033[36m%-22s\033[0m %s\n", $$1, $$NF }' $(MAKEFILE_LIST)

.PHONY: up down ps rmi logs build

DOCKER_COMPOSE	:= docker-compose -f docker-compose.yml --no-ansi
IMAGE_NAME	:= yamlssm-sample
ECR_NAME 	:= $(DOCKER_REGISTRY_ID).dkr.ecr.ap-northeast-1.amazonaws.com

### docker
build: ## Docker build
	@docker build . -t $(IMAGE_NAME):latest
	@docker build ./docker/mysql -t $(IMAGE_NAME)_mysql:latest

rmi: down##Docker rmi
	@docker rmi -f $(IMAGE_NAME):latest
	@docker rmi -f $(ECR_NAME)/$(IMAGE_NAME):latest
	@docker rmi -f $(IMAGE_NAME)_mysql:latest
	@docker rmi -f $(ECR_NAME)/$(IMAGE_NAME)_mysql:latest

up: ## compose立ち上げ
	@$(DOCKER_COMPOSE) up -d

down: ## composeのコンテナ削除
	-@$(DOCKER_COMPOSE) down

ps: ## composeの状態表示
	@$(DOCKER_COMPOSE) ps

logs: ## composeの状態表示
	@$(DOCKER_COMPOSE) logs -f

### ecs
### ECR
login: ## ECRにログイン
	@$$(aws ecr get-login --no-include-email --registry-ids $(DOCKER_REGISTRY_ID))

push: build login rm/ecr ## ECRにpush
	@aws ecr create-repository --repository-name $(IMAGE_NAME)
	@aws ecr create-repository --repository-name $(IMAGE_NAME)_mysql
	@docker tag $(IMAGE_NAME):latest $(DOCKER_REGISTRY_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME):latest
	@docker tag $(IMAGE_NAME)_mysql:latest $(DOCKER_REGISTRY_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME)_mysql:latest
	@docker push $(DOCKER_REGISTRY_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME):latest
	@docker push $(DOCKER_REGISTRY_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME)_mysql:latest

rm/ecr: login ## ECR削除
	@aws ecr delete-repository --repository-name $(IMAGE_NAME) --force
	@aws ecr delete-repository --repository-name $(IMAGE_NAME)_mysql --force

### ECS
prod/configure: ## my-clusterを定義する
	@ecs-cli configure profile --profile-name $(AWS_PROFILE)
	@ecs-cli configure --region ap-northeast-1 --cluster my-cluster

prod/create: ## ECSのクラスタ作成
	@ecs-cli up --capability-iam --force --keypair $(KEY_PAIR) --instance-type t2.medium

prod/up: ## ECSで立ち上げ
	@ecs-cli compose --file docker-compose_ecs.yml up

prod/down: ## ECS停止
	-@ecs-cli compose --file docker-compose_ecs.yml down

prod/down/all: ## クラスタインスタンス削除
	-@ecs-cli compose --file docker-compose_ecs.yml service rm
	@ecs-cli down -c my-cluster --force

prod/ps: ## ECSの状態表示
	@ecs-cli ps
