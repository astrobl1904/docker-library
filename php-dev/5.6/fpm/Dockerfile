# Development environment for sites with PHP running as PHP FastCGI backend.
# See the full README for all modules and settings.
# 
# Dockerfile based on the file of the official PHP container.

FROM centos:centos7
MAINTAINER Andreas Strobl <astroblx@asgraphics.at>

ENV PHP_VERSION=5.6.9 \
    PHP_INI_DIR=/etc \
    PHP_FPM_CONF_DIR=/etc \
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
        net-tools \
        php-fpm \
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
        php-xdebug

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

RUN { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
    && yum clean all && { rm -rf /var/cache/yum/* || true; } \
    && mv $PHP_INI_DIR/php.ini $PHP_INI_DIR/php.ini.dist \
    && mv $PHP_FPM_CONF_DIR/php-fpm.conf $PHP_FPM_CONF_DIR/php-fpm.conf.dist \
    && mkdir -p /var/spool/xdebug/{profiler,trace} && chown -R apache:apache /var/spool/xdebug \
    && { rm $PHP_FPM_CONF_DIR/php-fpm.d/* || true; }

COPY php.ini $PHP_INI_DIR/
COPY php-fpm.conf $PHP_FPM_CONF_DIR/

WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm"]

