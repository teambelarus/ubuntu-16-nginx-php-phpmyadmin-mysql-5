FROM 1and1internet/ubuntu-16-nginx-php-phpmyadmin:latest
MAINTAINER James Eckersall <james.eckersall@1and1.co.uk>
ARG DEBIAN_FRONTEND=noninteractive

COPY files/ /

ENV MYSQL_ROOT_PASSWORD=ReplaceWithENVFromBuild \
    DISABLE_PHPMYADMIN=0 \
    PMA_ARBITRARY=0 \
    PMA_HOST=localhost \
    MYSQL_GENERAL_LOG=0

RUN \
  groupadd mysql && \
  useradd -g mysql mysql && \
  apt-get update && \
  apt-get install -y mysql-server && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/lib/mysql && \
  mkdir --mode=0777 /var/lib/mysql /var/run/mysqld && \
  sed -r -i -e 's/^bind-address\s+=\s+127\.0\.0\.1$/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf && \
  sed -i -r -e 's/^#general_log_file\s+=.*/general_log_file=\/var\/log\/mysql\/mysql.log/g' /etc/mysql/mysql.conf.d/mysqld.cnf && \
  sed -i -r -e '/\[mysqld\]/a skip-host-cache\nskip-name-resolve\ninnodb_use_native_aio = 0' /etc/mysql/mysql.conf.d/mysqld.cnf && \
  chmod 777 /docker-entrypoint-initdb.d && \
  chmod -R 0777 /var/lib/mysql /var/log/mysql && \
  chmod -R 0775 /etc/mysql && \
  chmod -R 0755 /hooks
EXPOSE 3306 8080
