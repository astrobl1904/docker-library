# Development environment for sites with legacy PHP running as Apache module.
# See the full README for all modules and settings.
# 
# Some commands based on work of James Deathe's jdeathe/centos-ssh

FROM centos:centos6
MAINTAINER Andreas Strobl <astroblx@asgraphics.at>

ENV PHP_VERSION=5.3.3 \
    PHP_INI_DIR=/etc \
    APACHE_CONF_DIR=/etc/httpd \
    ORACLE_INSTANTCLIENT_VERSION=11.2.0.4 \
    TNS_ADMIN=/etc \
    LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib \
    NLS_LANG=GERMAN_AUSTRIA.WE8ISO8859P1

# Import the Centos-6 RPM GPG key to prevent warnings and Add EPEL Repository
RUN rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6 \
    && rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6 \
    && rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
    && yum -y update; yum clean all

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

# phpize deps
RUN yum --setopt=tsflags=nodocs -y install \
    autoconf \
    gcc \
    glibc \
    glibc-devel \
    make \
    pkgconfig \
    patch \
    bzip2 \
    file \
    tar

COPY oracle-instantclient*.x86_64.rpm /
COPY oracle-instantclient.x86_64.conf /etc/ld.so.conf.d/oracle-instantclient.x86_64.conf
COPY php_pdflib.so /usr/lib64/php/modules/php_pdflib.so
COPY licensekeys.txt /usr/local/PDFlib/licensekeys.txt

COPY pdo_oci.config.m4.patch /
RUN yum --setopt=tsflags=nodocs -y install \
    httpd \
    httpd-tools \
    && rm -rf /var/www/html && mkdir -p /var/www/html && chown -R apache:apache /var/www/html \
    && yum --setopt=tsflags=nodocs --nogpgcheck -y install \
        /oracle-instantclient.x86_64.rpm \
        /oracle-instantclient-devel.x86_64.rpm \
    && /bin/rm -f /oracle-instantclient*.x86_64.rpm \
    && mkdir -p $PHP_INI_DIR/php.d \
    && echo "# Placeholder tnsnames.ora for Docker containers" > $TNS_ADMIN/tnsnames.ora \
    && yum --setopt=tsflags=nodocs -y install \
        php \
        php-common \
        php-cli \
        php-gd \
        php-ldap \
        php-mbstring \
        php-mysql \
        php-pgsql \
        php-pdo \
        php-soap \
        php-xml \
        php-devel \
        php-pear \
    && pecl channel-update pecl.php.net \
    && pecl install oci8-2.0.8 \
    && echo '; Enable oci8 extension module' > $PHP_INI_DIR/php.d/20-oci8.ini \
    && echo 'extension=oci8.so' >> $PHP_INI_DIR/php.d/20-oci8.ini \
    && pecl install xdebug-2.2.7 \
    && echo '; Enable xdebug extension module' > $PHP_INI_DIR/php.d/99-xdebug.ini \
    && echo 'zend_extension="/usr/lib64/php/modules/xdebug.so"' >> $PHP_INI_DIR/php.d/99-xdebug.ini \
    && echo '[xdebug]' >> $PHP_INI_DIR/php.d/99-xdebug.ini \
    && echo 'xdebug.remote_enable = 1' >> $PHP_INI_DIR/php.d/99-xdebug.ini \
    && echo 'xdebug.remote_connect_back = 1' >> $PHP_INI_DIR/php.d/99-xdebug.ini \
    && echo 'xdebug.profiler_enable_trigger = 1' >> $PHP_INI_DIR/php.d/99-xdebug.ini \
    && echo 'xdebug.profiler_output_dir = "/var/spool/xdebug/profiler"' >> $PHP_INI_DIR/php.d/99-xdebug.ini \
    && echo 'xdebug.trace_output_dir = "/var/spool/xdebug/trace"' >> $PHP_INI_DIR/php.d/99-xdebug.ini \
    && curl -SL "http://museum.php.net/php5/php-5.3.3.tar.bz2" -o php.tar.bz2 \
    && mkdir /usr/src/php \
    && tar -xf php.tar.bz2 -C /usr/src/php --strip-components=1 \
    && rm php.tar.bz2 \
    && cd /usr/src/php/ext/pdo_oci \
    && patch -p0 < /pdo_oci.config.m4.patch && rm /pdo_oci.config.m4.patch \
    && phpize \
    && /usr/src/php/ext/pdo_oci/configure --with-pdo-oci=shared,instantclient,/usr,11.2 \
    && make -j$(nproc) \
    && make install \
    && cd /usr/src \
    && rm -rf /usr/src/php \
    && echo '; Enable pdo_oci extension module' > $PHP_INI_DIR/php.d/30-pdo_oci.ini \
    && echo 'extension=pdo_oci.so' >> $PHP_INI_DIR/php.d/30-pdo_oci.ini \
    && mv $PHP_INI_DIR/php.d/pdo.ini $PHP_INI_DIR/php.d/20-pdo.ini \
    && mv $PHP_INI_DIR/php.d/mysqli.ini $PHP_INI_DIR/php.d/20-mysqli.ini \
    && mv $PHP_INI_DIR/php.d/mysql.ini $PHP_INI_DIR/php.d/20-mysql.ini \
    && mv $PHP_INI_DIR/php.d/pgsql.ini $PHP_INI_DIR/php.d/20-pgsql.ini \
    && mv $PHP_INI_DIR/php.d/sqlite3.ini $PHP_INI_DIR/php.d/20-sqlite3.ini \
    && mv $PHP_INI_DIR/php.d/pdo_mysql.ini $PHP_INI_DIR/php.d/30-pdo_mysql.ini \
    && mv $PHP_INI_DIR/php.d/pdo_sqlite.ini $PHP_INI_DIR/php.d/30-pdo_sqlite.ini \
    && mv $PHP_INI_DIR/php.d/pdo_pgsql.ini $PHP_INI_DIR/php.d/30-pdo_pgsql.ini \
    && mkdir -p /usr/local/PDFlib/PDFlib/9.0 \
    && echo '; Enable pdflib extension module' > $PHP_INI_DIR/php.d/99-pdflib.ini \
    && echo 'extension="/usr/lib64/php/modules/php_pdflib.so"' >> $PHP_INI_DIR/php.d/99-pdflib.ini \
    && yum -y erase \
        php-pear \
        gcc \
        glibc-devel \
        patch \
        bzip2 \
        file \
        tar \
        cloog-ppl \
        cpp \
        glibc-headers \
        kernel-headers \
        libgomp \
        m4 \
        mpfr \
        perl \
        perl-Module-Pluggable \
        perl-Pod-Escapes \
        perl-Pod-Simple \
        perl-libs \
        perl-version \
        ppl \
    && { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
    && yum clean all && { rm -rf /var/cache/yum/* || true; } \
    && mv $PHP_INI_DIR/php.ini $PHP_INI_DIR/php.ini.dist \
    && mv $APACHE_CONF_DIR/conf/httpd.conf $APACHE_CONF_DIR/conf/httpd.conf.dist \
    && mkdir -p $APACHE_CONF_DIR/sites \
    && { rm $APACHE_CONF_DIR/conf.d/* $APACHE_CONF_DIR/sites/* || true; }
COPY php.ini $PHP_INI_DIR/php.ini
COPY httpd.conf $APACHE_CONF_DIR/conf/
COPY vhost.template $APACHE_CONF_DIR/sites/

WORKDIR /var/www/html

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

CMD ["httpd"]
