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
