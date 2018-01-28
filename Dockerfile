FROM golang:1.9.2-alpine

ENV SRC=/go/src/github.com/sioncojp/yamlssm-sample/

WORKDIR /app
COPY . $SRC
COPY docker-entrypoint.sh /
RUN cd $SRC; go build -o /app/yamlssm-sample cmd/yamlssm-sample/main.go
RUN cd $SRC; cp config.yml /app/

ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]
EXPOSE 8080
