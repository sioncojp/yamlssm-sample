#!/bin/sh

echo "CREATE DATABASE IF NOT EXISTS \`hoge\` ;" | "${mysql[@]}"
echo "CREATE DATABASE IF NOT EXISTS \`hoge_dev\` ;" | "${mysql[@]}"
echo "GRANT ALL ON \`hoge_dev\`.* TO 'dev'@'%' IDENTIFIED BY 'dev' ;" | "${mysql[@]}"
echo "GRANT ALL ON \`hoge\`.* TO 'root'@'%' IDENTIFIED BY 'getwild' ;" | "${mysql[@]}"
echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"

mysql -uroot --protocol=socket -proot hoge < /docker-entrypoint-initdb.d/hoge.sql_
mysql -uroot --protocol=socket -proot hoge_dev < /docker-entrypoint-initdb.d/hoge_dev.sql_
