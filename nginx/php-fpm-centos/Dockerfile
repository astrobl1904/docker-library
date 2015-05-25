FROM centos:centos7
MAINTAINER Andreas Strobl <astroblx@asgraphics.at>

ENV NGINX_CONF_DIR=/etc/nginx

# Enable EPEL & Remi Repository and update system
RUN curl -o /tmp/epel-release-7-5.noarch.rpm -SL "http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm" \
    && rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 \
    && rpm -ivh /tmp/epel-release-7-5.noarch.rpm \
    && curl -o /tmp/remi-release-7.rpm -SL "http://rpms.famillecollet.com/enterprise/remi-release-7.rpm" \
    && rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi \
    && rpm -ivh /tmp/remi-release-7.rpm \
    && awk 'BEGIN { changeRepoState = "false"; }                \
        /^\[[^\]]+\]/ {                                         \
            section = $0;                                       \
            gsub(/[\[\]]/, "", section);                        \
            if (section == "remi" || section == "remi-php56") { \
                changeRepoState = "true";                       \
            } else {                                            \
                changeRepoState = "false";                      \
            }                                                   \
        }                                                       \
        {                                                       \
            if (changeRepoState == "false") {                   \
                print $0;                                       \
            } else {                                            \
                split($0, kvpair, "=");                         \
                if (kvpair[1] == "enabled") {                   \
                    print "enabled=1";                          \
                } else {                                        \
                    print $0;                                   \
                }                                               \
            }                                                   \
        }' /etc/yum.repos.d/remi.repo > /etc/yum.repos.d/remi.repo.tmp \
    && cp /etc/yum.repos.d/remi.repo.tmp /etc/yum.repos.d/remi.repo \
    && rm -f /etc/yum.repos.d/remi.repo.tmp \
    && yum --setopt=tsflags=nodocs -y update && yum clean all \
    && rm -f /tmp/*.rpm

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

