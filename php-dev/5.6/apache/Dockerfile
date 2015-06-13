# Development environment for sites with PHP running as Apache module.
# See the full README for all modules and settings.
# 
# Dockerfile based on the file of the official PHP container.

FROM centos:centos7
MAINTAINER Andreas Strobl <astroblx@asgraphics.at>

ENV PHP_VERSION=5.6.10 \
    PHP_INI_DIR=/etc \
    APACHE_CONF_DIR=/etc/httpd \
    ORACLE_INSTANTCLIENT_VERSION=12.1.0.2 \
    TNS_ADMIN=/etc \
    LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib \
    NLS_LANG=GERMAN_AUSTRIA.WE8ISO8859P15
    
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

COPY oracle-instantclient*.x86_64.rpm /tmp/
COPY oracle-instantclient.x86_64.conf /etc/ld.so.conf.d/oracle-instantclient.x86_64.conf
COPY php_pdflib.so /usr/lib64/php/modules/php_pdflib.so
COPY licensekeys.txt /usr/local/PDFlib/licensekeys.txt

RUN yum --setopt=tsflags=nodocs --nogpgcheck -y install \
        /tmp/oracle-instantclient.x86_64.rpm \
        /tmp/oracle-instantclient-devel.x86_64.rpm \
    && /bin/rm -f /tmp/oracle-instantclient*.x86_64.rpm \
    && echo "# Placeholder tnsnames.ora for Docker containers" > $TNS_ADMIN/tnsnames.ora \
    && yum --setopt=tsflags=nodocs -y install \
        httpd \
        httpd-tools \
        php \
        php-common \
        php-cli \
        php-gd \
        php-ldap \
        php-mbstring \
        php-mysql \
        php-pgsql \
        php-oci8 \
        php-pdo \
        php-soap \
        php-xml \
        php-pear \
        php-xdebug \
    && rm -rf /var/www/html && mkdir -p /var/www/html && chown -R apache:apache /var/www/html

RUN echo '; Enable xdebug extension module' > $PHP_INI_DIR/php.d/15-xdebug.ini \
    && echo 'zend_extension=xdebug.so' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
    && echo '[xdebug]' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
    && echo 'xdebug.remote_enable = 1' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
    && echo 'xdebug.remote_connect_back = 1' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
    && echo 'xdebug.profiler_enable_trigger = 1' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
    && echo 'xdebug.profiler_output_dir = "/var/spool/xdebug/profiler"' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
    && echo 'xdebug.trace_output_dir = "/var/spool/xdebug/trace"' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
    && mkdir -p /usr/local/PDFlib/PDFlib/9.0 \
    && echo '; Enable pdflib extension module' > $PHP_INI_DIR/php.d/15-pdflib.ini \
    && echo 'extension="/usr/lib64/php/modules/php_pdflib.so"' >> $PHP_INI_DIR/php.d/15-pdflib.ini

RUN curl -o /tmp/phpunit.phar -SL "https://phar.phpunit.de/phpunit.phar" \
    && chmod +x /tmp/phpunit.phar \
    && mv /tmp/phpunit.phar /usr/local/bin/phpunit \
    && { curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer.phar; } \
    && { ln -s /usr/local/bin/composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer.phar; } \
    && curl -o /tmp/pdepend.phar -sSL "http://static.pdepend.org/php/latest/pdepend.phar" \
    && chmod +x /tmp/pdepend.phar \
    && mv /tmp/pdepend.phar /usr/local/bin \
    && ln -s /usr/local/bin/pdepend.phar /usr/local/bin/pdepend \
    && curl -o /tmp/phpmd.phar -sSL "http://static.phpmd.org/php/latest/phpmd.phar" \
    && chmod +x /tmp/phpmd.phar \
    && mv /tmp/phpmd.phar /usr/local/bin \
    && ln -s /usr/local/bin/phpmd.phar /usr/local/bin/phpmd \
    && curl -o /tmp/phpcpd.phar -sSL "https://phar.phpunit.de/phpcpd.phar" \
    && chmod +x /tmp/phpcpd.phar \
    && mv /tmp/phpcpd.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpcpd.phar /usr/local/bin/phpcpd \
    && curl -o /tmp/phploc.phar -sSL "https://phar.phpunit.de/phploc.phar" \
    && chmod +x /tmp/phploc.phar \
    && mv /tmp/phploc.phar /usr/local/bin \
    && ln -s /usr/local/bin/phploc.phar /usr/local/bin/phploc \
    && curl -o /tmp/phpdcd.phar -sSL "https://phar.phpunit.de/phpdcd.phar" \
    && chmod +x /tmp/phpdcd.phar \
    && mv /tmp/phpdcd.phar /usr/local/bin \
    && ln -s /usr/local/bin/phpdcd.phar /usr/local/bin/phpdcd \
    && curl -o /tmp/de-legacy-fy.phar -sSL "https://phar.phpunit.de/de-legacy-fy.phar" \
    && chmod +x /tmp/de-legacy-fy.phar \
    && mv /tmp/de-legacy-fy.phar /usr/local/bin \
    && ln -s /usr/local/bin/de-legacy-fy.phar /usr/local/bin/de-legacy-fy \
    && curl -o /tmp/phpcs.phar -sSL "https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar" \
    && chmod +x /tmp/phpcs.phar \
    && mv /tmp/phpcs.phar /usr/local/bin \
    && ln -s /usr/local/bin/phpcs.phar /usr/local/bin/phpcs \
    && curl -o /tmp/phpdox.phar -sSL "http://phpdox.de/releases/phpdox.phar" \
    && chmod +x /tmp/phpdox.phar \
    && mv /tmp/phpdox.phar /usr/local/bin \
    && ln -s /usr/local/bin/phpdox.phar /usr/local/bin/phpdox \
    && curl -o /tmp/hhvm-wrapper.phar -sSL "https://phar.phpunit.de/hhvm-wrapper.phar" \
    && chmod +x /tmp/hhvm-wrapper.phar \
    && mv /tmp/hhvm-wrapper.phar /usr/local/bin \
    && ln -s /usr/local/bin/hhvm-wrapper.phar /usr/local/bin/hhvm-wrapper \
    && curl -o /tmp/behat.phar -sSL "https://github.com/Behat/Behat/releases/download/v2.5.5/behat.phar" \
    && chmod +x /tmp/behat.phar \
    && mv /tmp/behat.phar /usr/local/bin \
    && ln -s /usr/local/bin/behat.phar /usr/local/bin/behat

RUN { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
    && yum clean all && { rm -rf /var/cache/yum/* || true; } \
    && { rm -rf /tmp/* || true; } \
    && mv $PHP_INI_DIR/php.ini $PHP_INI_DIR/php.ini.dist \
    && mv $APACHE_CONF_DIR/conf/httpd.conf $APACHE_CONF_DIR/conf/httpd.conf.dist \
    && mkdir -p ${APACHE_CONF_DIR}/sites \
    && mkdir -p /var/spool/xdebug/{profiler,trace} && chown -R apache:apache /var/spool/xdebug \
    && { rm ${APACHE_CONF_DIR}/conf.d/* ${APACHE_CONF_DIR}/sites/* || true; }

COPY php.ini $PHP_INI_DIR/php.ini
COPY httpd.conf $APACHE_CONF_DIR/conf/
COPY vhost.template $APACHE_CONF_DIR/sites/

WORKDIR /var/www/html

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

CMD ["httpd"]
