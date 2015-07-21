FROM centos:centos7
MAINTAINER Andreas Strobl <astroblx@asgraphics.at>

ENV NGINX_CONF_DIR=/etc/nginx \
    NGINX_VERSION=1.8.0 \
    PHP_FPM_BACKEND_SERVER=127.0.0.1:9000

# Enable EPEL & Remi Repository and update system
RUN yum install -y http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

RUN yum --setopt=tsflags=nodocs -y update && yum clean all
RUN yum --setopt=tsflags=nodocs -y install \
        nginx \
        net-tools \
    && rm -rf /var/www/html && mkdir -p /var/www/html \
    && { mkdir -p /etc/nginx/sites && mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.dist || true; }

RUN { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
    && yum clean all && { rm -rf /var/cache/yum/* || true; }

COPY nginx-site.template $NGINX_CONF_DIR/sites/
COPY php-fpm-backend.conf $NGINX_CONF_DIR/conf.d/php-fpm-backend.conf
COPY nginx.conf $NGINX_CONF_DIR/nginx.conf
COPY docker-entrypoint.sh /

WORKDIR /var/www/html

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

CMD ["nginx"]

