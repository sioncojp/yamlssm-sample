FROM mysql

COPY ./script/database.sh /docker-entrypoint-initdb.d/database.sh
COPY ./script/hoge.sql_ /docker-entrypoint-initdb.d/hoge.sql_
COPY ./script/hoge_dev.sql_ /docker-entrypoint-initdb.d/hoge_dev.sql_
