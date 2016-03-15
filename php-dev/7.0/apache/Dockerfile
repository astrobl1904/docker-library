# Development environment for sites with PHP running as Apache module.
# See the full README for all modules and settings.
# 
# Dockerfile based on the file of the official PHP container.

FROM centos:centos7
MAINTAINER Andreas Strobl <astroblx@asgraphics.at>

ENV PHP_VERSION=7.0.4 \
    PHP_INI_DIR=/etc \
    APACHE_CONF_DIR=/etc/httpd \
    ORACLE_INSTANTCLIENT_VERSION=12.1.0.2 \
    TNS_ADMIN=/etc \
    LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib \
    NLS_LANG=GERMAN_AUSTRIA.WE8ISO8859P15

# Enable EPEL and update system
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
            if (section == "remi" || section == "remi-php70") { \
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
        }' /etc/yum.repos.d/remi-php70.repo > /etc/yum.repos.d/remi-php70.repo.tmp \
    && cp /etc/yum.repos.d/remi-php70.repo.tmp /etc/yum.repos.d/remi-php70.repo \
    && rm -f /etc/yum.repos.d/remi-php70.repo.tmp \
    && yum --setopt=tsflags=nodocs -y update && yum clean all \
    && rm -f /tmp/*.rpm

COPY enable-zsh-zprezto /tmp/
COPY licensekeys.txt /usr/local/PDFlib/licensekeys.txt

RUN yum --setopt=tsflags=nodocs -y install tar \
    && curl -o /tmp/pdflib-php.tar.gz -SL "http://www.pdflib.com/binaries/PDFlib/906/PDFlib-9.0.6p2-Linux-x86_64-php.tar.gz" \
    && mkdir -p /usr/lib64/php/modules \
    && tar -xzf /tmp/pdflib-php.tar.gz -C /usr/lib64/php/modules --no-same-owner --no-same-permissions --strip-components=4 */php-700/php_pdflib.so
#    && curl -o /tmp/oracle-instantclient.x86_64.rpm -SL 'http://download.oracle.com/otn/linux/instantclient/121020/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm?AuthParam=1458004105_58860af3ab5e89ae24b13a8878ec3dcc' \
#     && yum --setopt=tsflags=nodocs --nogpgcheck -y install /tmp/oracle-instantclient.x86_64.rpm \
#     && echo "/usr/lib/oracle/12.1/client64/lib" > /etc/ld.so.conf.d/oracle-instantclient.x86_64.conf \
#     && echo "# Placeholder tnsnames.ora for Docker containers" > $TNS_ADMIN/tnsnames.ora \
#     && rm -rf /tmp/*.rpm /tmp/*.tar.gz
#     && yum --setopt=tsflags=nodocs -y install \
#         git \
#         httpd \
#         httpd-tools \
#         net-tools \
#         php \
#         php-bcmath \
#         php-cli \
#         php-common \
#         php-gd \
#         php-ldap \
#         php-mbstring \
#         php-mysqlnd \
#         php-oci8 \
#         php-opcache \
#         php-pdo \
#         php-pear \
#         php-pecl-xdebug \
#         php-pgsql \
#         php-soap \
#         php-xml \
#         zsh \
#     && rm -rf /var/www/html && mkdir -p /var/www/html && chown -R apache:apache /var/www/html \
# 
# RUN echo '; Enable xdebug extension module' > $PHP_INI_DIR/php.d/15-xdebug.ini \
#     && echo 'zend_extension=xdebug.so' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
#     && echo '[xdebug]' >> $PHP_INI_DIR/php.d/20-xdebug.ini \
#     && echo 'xdebug.remote_enable = 1' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
#     && echo 'xdebug.remote_connect_back = 1' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
#     && echo 'xdebug.profiler_enable_trigger = 1' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
#     && echo 'xdebug.profiler_output_dir = "/var/spool/xdebug/profiler"' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
#     && echo 'xdebug.trace_output_dir = "/var/spool/xdebug/trace"' >> $PHP_INI_DIR/php.d/15-xdebug.ini \
#     && install -m 755 -d /usr/local/PDFlib/PDFlib/9.0 \
#     && echo '; Enable php_pdflib extension module' > $PHP_INI_DIR/php.d/20-php_pdflib.ini \
#     && echo 'extension="/usr/lib64/php/modules/php_pdflib.so"' >> $PHP_INI_DIR/php.d/20-php_pdflib.ini
# 
# RUN git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
# RUN chmod 755 /tmp/enable-zsh-zprezto
# RUN /tmp/enable-zsh-zprezto & chsh -s /bin/zsh
# 
# RUN curl -o /tmp/phpunit.phar -SL "https://phar.phpunit.de/phpunit.phar" \
#     && chmod +x /tmp/phpunit.phar \
#     && mv /tmp/phpunit.phar /usr/local/bin/phpunit \
#     && { curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer.phar; } \
#     && { ln -s /usr/local/bin/composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer.phar; } \
#     && curl -o /tmp/pdepend.phar -sSL "http://static.pdepend.org/php/latest/pdepend.phar" \
#     && chmod +x /tmp/pdepend.phar \
#     && mv /tmp/pdepend.phar /usr/local/bin \
#     && ln -s /usr/local/bin/pdepend.phar /usr/local/bin/pdepend \
#     && curl -o /tmp/phpmd.phar -sSL "http://static.phpmd.org/php/latest/phpmd.phar" \
#     && chmod +x /tmp/phpmd.phar \
#     && mv /tmp/phpmd.phar /usr/local/bin \
#     && ln -s /usr/local/bin/phpmd.phar /usr/local/bin/phpmd \
#     && curl -o /tmp/phpcpd.phar -sSL "https://phar.phpunit.de/phpcpd.phar" \
#     && chmod +x /tmp/phpcpd.phar \
#     && mv /tmp/phpcpd.phar /usr/local/bin/ \
#     && ln -s /usr/local/bin/phpcpd.phar /usr/local/bin/phpcpd \
#     && curl -o /tmp/phploc.phar -sSL "https://phar.phpunit.de/phploc.phar" \
#     && chmod +x /tmp/phploc.phar \
#     && mv /tmp/phploc.phar /usr/local/bin \
#     && ln -s /usr/local/bin/phploc.phar /usr/local/bin/phploc \
#     && curl -o /tmp/phpdcd.phar -sSL "https://phar.phpunit.de/phpdcd.phar" \
#     && chmod +x /tmp/phpdcd.phar \
#     && mv /tmp/phpdcd.phar /usr/local/bin \
#     && ln -s /usr/local/bin/phpdcd.phar /usr/local/bin/phpdcd \
#     && curl -o /tmp/de-legacy-fy.phar -sSL "https://phar.phpunit.de/de-legacy-fy.phar" \
#     && chmod +x /tmp/de-legacy-fy.phar \
#     && mv /tmp/de-legacy-fy.phar /usr/local/bin \
#     && ln -s /usr/local/bin/de-legacy-fy.phar /usr/local/bin/de-legacy-fy \
#     && curl -o /tmp/phpcs.phar -sSL "https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar" \
#     && chmod +x /tmp/phpcs.phar \
#     && mv /tmp/phpcs.phar /usr/local/bin \
#     && ln -s /usr/local/bin/phpcs.phar /usr/local/bin/phpcs \
#     && curl -o /tmp/phpdox.phar -sSL "http://phpdox.de/releases/phpdox.phar" \
#     && chmod +x /tmp/phpdox.phar \
#     && mv /tmp/phpdox.phar /usr/local/bin \
#     && ln -s /usr/local/bin/phpdox.phar /usr/local/bin/phpdox \
#     && curl -o /tmp/hhvm-wrapper.phar -sSL "https://phar.phpunit.de/hhvm-wrapper.phar" \
#     && chmod +x /tmp/hhvm-wrapper.phar \
#     && mv /tmp/hhvm-wrapper.phar /usr/local/bin \
#     && ln -s /usr/local/bin/hhvm-wrapper.phar /usr/local/bin/hhvm-wrapper \
#     && curl -o /tmp/behat.phar -sSL "https://github.com/Behat/Behat/releases/download/v2.5.5/behat.phar" \
#     && chmod +x /tmp/behat.phar \
#     && mv /tmp/behat.phar /usr/local/bin \
#     && ln -s /usr/local/bin/behat.phar /usr/local/bin/behat \
#     && curl -o /tmp/phpab.phar -sSL "https://github.com/theseer/Autoload/releases/download/1.20.0/phpab-1.20.0.phar" \
#     && chmod +x /tmp/phpab.phar \
#     && mv /tmp/phpab.phar /usr/local/bin \
#     && ln -s /usr/local/bin/phpab.phar /usr/local/bin/phpab
# 
# RUN { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
#     && yum clean all && { rm -rf /var/cache/yum/* || true; } \
#     && { rm -rf /tmp/* || true; } \
#     && mv $PHP_INI_DIR/php.ini $PHP_INI_DIR/php.ini.dist \
#     && mv $APACHE_CONF_DIR/conf/httpd.conf $APACHE_CONF_DIR/conf/httpd.conf.dist \
#     && mkdir -p ${APACHE_CONF_DIR}/sites \
#     && mkdir -p /var/spool/xdebug/{profiler,trace} && chown -R apache:apache /var/spool/xdebug \
#     && { rm ${APACHE_CONF_DIR}/conf.d/* ${APACHE_CONF_DIR}/sites/* || true; }
# 
# COPY php.ini $PHP_INI_DIR/php.ini
# COPY httpd.conf $APACHE_CONF_DIR/conf/
# COPY vhost.template $APACHE_CONF_DIR/sites/
# 
# WORKDIR /var/www/html
# 
# COPY docker-entrypoint.sh /
# 
# ENTRYPOINT ["/docker-entrypoint.sh"]
# 
# EXPOSE 80
# 
# CMD ["httpd"]
