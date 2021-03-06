FROM 1and1internet/ubuntu-16-nginx-php-phpmyadmin:latest
MAINTAINER Brian Wojtczak <brian.wojtczak@1and1.co.uk>
ARG DEBIAN_FRONTEND=noninteractive

COPY files/ /

RUN \
  groupadd mysql && \
  useradd -g mysql mysql && \
  apt-get update && \
  apt-get install -y gettext-base mysql-server pwgen && \
  rm -rf /var/lib/apt/lists/* /var/lib/mysql /etc/mysql* && \
  mkdir --mode=0777 /var/lib/mysql /var/run/mysqld /etc/mysql && \
  chmod 0777 /docker-entrypoint-initdb.d && \
  chmod -R 0775 /etc/mysql && \
  chmod -R 0755 /hooks && \
  chmod -R 0777 /var/log/mysql && \
  cd /opt/configurability/src/mysql_config_translator && \
  pip --no-cache install --upgrade pip && \
  pip --no-cache install --upgrade .

#install ioncube
RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
RUN tar xvfz ioncube_loaders_lin_x86-64.tar.gz
RUN cp ioncube/*.so /usr/lib/php5/2*/
RUN echo zend_extension = /usr/lib/php5/2*/ioncube_loader_lin_5.6.so > /etc/php5/apache2/conf.d/00-ioncube.ini

ENV DISABLE_PHPMYADMIN=0 \
    PMA_ARBITRARY=0 \
    PMA_HOST=localhost \
    MYSQL_GENERAL_LOG=0 \
    MYSQL_QUERY_CACHE_TYPE=1 \
    MYSQL_QUERY_CACHE_SIZE=16M \
    MYSQL_QUERY_CACHE_LIMIT=1M

EXPOSE 3306 8080
VOLUME /var/lib/mysql/
