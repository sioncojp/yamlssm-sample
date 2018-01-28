### やったこと

* yamlssm を使うには AWS_REGION を export する必要がある
* parameter store 登録（mysql.password: getwild） SecureString は KMS 使用してるからリクエスト毎で費用かかるけど大したことないよ

```shell
$ export AWS_PROFILE=xxxxx; aws ssm get-parameters --region ap-northeast-1 --name prod.yamlssm-sample.mysql.password --with-decryption
{
    "Parameters": [
        {
            "Name": "prod.yamlssm-sample.mysql.password",
            "Type": "SecureString",
            "Value": "getwild",
            "Version": 1
        }
    ],
    "InvalidParameters": []
}
```

```shell
### direnvで環境変数set
$ cd sample-app-go
$ brew install direnv
$ vim ~/.bashrc
eval "$(direnv hook bash)"

$ vim .envrc
export AWS_ACCESS_KEY_ID=xxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxx
export AWS_REGION=ap-northeast-1

$ direnv allow

### docker-compose立ち上げ
$ make -f docker.mk build
$ make -f docker.mk up

### development
$ curl localhost:80

### production
$ curl localhost:81

### 落とす時
$ make -f docker.mk down

### イメージ削除
$ make -f docker.mk rmi
```

### For ECS

```shell
### ecs-cliのインストール
$ brew install amazon-ecs-cli
$ ecs-cli --version
ecs-cli version 1.3.0 (*UNKNOWN)

### direnvで環境変数set
$ cd sample-app-go
$ brew install direnv
$ vim ~/.bashrc
eval "$(direnv hook bash)"

$ vim .envrc
export AWS_PROFILE=xxxxxx
export AWS_ACCESS_KEY_ID=xxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxx
export AWS_REGION=ap-northeast-1
export DOCKER_REGISTRY_ID=xxxxxx
export KEY_PAIR=xxxxxx

$ direnv allow

### ECRにpush
### 事前にコンソールでyamlssm-sampleとyamlssm-sample_mysqlリポジトリを作る
$ make -f docker.mk push

### ecs用のyml作成
$ vim docker-compose_ecs.yml
mysql:
  image: xxxx.dkr.ecr.ap-northeast-1.amazonaws.com/yamlssm-sample_mysql:latest
  container_name: "yamlssm-sample_mysql"
  ports:
    - "3306:3306"
  environment:
    MYSQL_ROOT_PASSWORD: root
  tty: true
app:
  image: xxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/yamlssm-sample:latest
  container_name: "yamlssm-sample"
  environment:
    - APP_ENV=production
    - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
    - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
    - AWS_REGION=${AWS_REGION}
  ports:
    - "80:8080"
  links:
    - mysql

### ecs cluster作成
$ make -f docker.mk prod/configure
$ make -f docker.mk prod/create
$ make -f docker.mk prod/up
$ make -f docker.mk prod/ps

### 削除
$ make -f docker.mk prod/down/all
$ make -f docker.mk rm/ecr
```
