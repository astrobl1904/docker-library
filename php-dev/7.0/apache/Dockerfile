# Development environment for sites with PHP running as Apache module.
# See the full README for all modules and settings.
# 
# Dockerfile based on the file of the official PHP container.

FROM centos:centos7
MAINTAINER Andreas Strobl <astroblx@asgraphics.at>

ENV PHP_VERSION=7.0.0beta3 \
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
    && yum --setopt=tsflags=nodocs -y update

COPY oracle-instantclient*.x86_64.rpm /tmp/
COPY oracle-instantclient.x86_64.conf /etc/ld.so.conf.d/oracle-instantclient.x86_64.conf

RUN yum --setopt=tsflags=nodocs --nogpgcheck -y install \
        /tmp/oracle-instantclient.x86_64.rpm \
        /tmp/oracle-instantclient-devel.x86_64.rpm \
    && /bin/rm -f /tmp/oracle-instantclient*.x86_64.rpm \
    && echo "# Placeholder tnsnames.ora for Docker containers" > $TNS_ADMIN/tnsnames.ora \
    && yum --setopt=tsflags=nodocs -y install \
        net-tools \
        httpd \
        httpd-tools

# Get Dev-Tools
RUN yum --setopt=tsflags=nodocs -y install \
        tar \
        gcc \
        gcc-c++ \
            # Dependencies: cpp, glibc-headers, libmpc, libstdc++-devel
        make \
        patch \
        libtool \
            # Dependencies: autoconf, automake, m4, perl, perl-Carp, perl-Data-Dumper, perl-Encode,
            #               perl-Exporter, perl-File-Path, perl-File-Temp, perl-Filter, perl-Getopt-Long,
            #               perl-HTTP-Tiny, perl-PathTools, perl-Pod-Escapes, perl-Pod-Perldoc, perl-Pod-Simple,
            #               perl-Pod-Usage, perl-Scalar-List-Utils, perl-Socket, perl-Storable, perl-Test-Harness,
            #               perl-Text-ParseWords, perl-Thread-Queue, perl-Time-HiRes, perl-Time-Local, perl-constant,
            #               perl-libs, perl-macros, perl-parent, perl-podlators, perl-threads, perl-threads-shared
        libxml2 \
            # Requires: libxml2-devel
            libxml2-devel
                # Dependencies: xz-devel, zlib-devel

# Configure Dependencies
RUN yum --setopt=tsflags=nodocs -y install \
        httpd-devel \
            # Dependencies: apr-devel, apr-util-devel, expat-devel
        systemtap-sdt-devel \
            # Dependencies: pyparsing
        openssl-devel \
            # Dependencies:  keyutils-libs-devel, krb5-devel, libcom_err-devel, libselinux-devel,
            #                libsepol-devel, libverto-devel, pcre-devel
        bzip2-devel \
        libcurl-devel \
        compat-db47 \
            # Dependencies: compat-db-headers
        tokyocabinet-devel \
            # Dependencies: tokyocabinet
        enchant-devel \
            # Dependencies: enchant, glib2-devel, hunspell, hunspell-en-US, hunspell-de
        libvpx-devel \
            # Dependencies: libvpx
        libjpeg-turbo-devel \
            # Dependencies: libjpeg-turbo
        libpng-devel \
            # Dependencies: libpng
        libXpm-devel \
            # Dependencies: libICE, libSM, libX11, libX11-common, libX11-devel, libXau, libXau-devel,
            #               libXext, libXpm, libXt, libxcb, libxcb-devel, xorg-x11-proto-devel
        freetype-devel \
            # Dependencies: freetype
        #t1lib-devel \
            # Dependencies: t1lib
        gmp-devel \
        libc-client-devel \
            # Dependencies: uw-imap-devel
        libicu-devel \
            # Dependencies: libicu
        openldap-devel \
            # Dependencies: cyrus-sasl, cyrus-sasl-devel, hostname, initscripts, kmod, sysvinit-tools
        libmcrypt-devel \
            # Dependencies: libmcrypt
        freetds-devel \
            # Dependencies: freetds, gnutls, libtool-ltdl, nettle, trousers
        unixODBC-devel \
            # Dependencies: unixODBC
        postgresql-devel \
            # Dependencies: postgresql, postgresql-libs
        sqlite-devel \
        aspell-devel \
            # Dependencies: aspell
        libedit-devel \
            # Dependencies: libedit, ncurses-devel
        net-snmp-devel \
            # Dependencies: elfutils-devel, elfutils-libelf-devel, elfutils-libs, libdb-devel,
            #               lm_sensors-devel, lm_sensors-libs, net-snmp-agent-libs, net-snmp-libs,
            #               perl-ExtUtils-Install, perl-ExtUtils-MakeMaker, perl-ExtUtils-Manifest,
            #               perl-ExtUtils-ParseXS, perl-devel, popt-devel, rpm-devel, tcp_wrappers-devel,
            #               tcp_wrappers-libs
        libtidy-devel \
            # Dependencies: libtidy
        libxslt-devel
            # Dependencies: libxslt, libgcrypt-devel, libgpg-error-devel

# Get Sources
COPY p01-configure-ltdl.patch /usr/src/php/p01.patch
RUN mkdir -p /usr/src/php/php-7.0 \
    && curl -o /usr/src/php/php-7.0.tar.gz -SL "https://downloads.php.net/~ab/php-7.0.0beta3.tar.gz" \
    && tar -xzf /usr/src/php/php-7.0.tar.gz --directory=/usr/src/php/php-7.0 --strip-components=1 \
    && cd /usr/src/php/php-7.0 \
    && cat `aclocal --print-ac-dir`/{libtool,ltoptions,ltsugar,ltversion,lt~obsolete}.m4 >>aclocal.m4 \
    && libtoolize --force --copy \
    && cat `aclocal --print-ac-dir`/{libtool,ltoptions,ltsugar,ltversion,lt~obsolete}.m4 >build/libtool.m4 \
    && touch configure.in \
    && ./buildconf --force \
    && ln -s /usr/include/db4.7.25 /usr/include/db4.7 \
    && patch < /usr/src/php/p01.patch

RUN cd /usr/src/php/php-7.0 \
    && env CFLAGS="-fno-strict-aliasing -Wno-pointer-sign" \
        EXTENSION_DIR="/usr/lib64/php/modules" \
        PEAR_INSTALLDIR="/usr/share/pear" ./configure \
            --cache-file=./config.cache \
            --prefix=/usr \
            --sysconfdir=/etc \
            --libdir=/usr/lib64 \
            --localstatedir=/var \
            --with-libdir=lib64 \
            --with-config-file-path=$PHP_INI_DIR \
            --with-config-file-scan-dir=$PHP_INI_DIR/php.d \
            --with-pic \
            --with-apxs2 \
            --disable-rpath \
            --without-pear \
            --disable-fpm \
            --enable-phpdbg \
            --enable-phpdbg-webhelper \
            --with-freetype-dir=/usr \
            --with-png-dir=/usr \
            --with-xpm-dir=/usr \
            --enable-gd-native-ttf \
            --without-gdbm \
            --with-jpeg-dir=/usr \
            --with-openssl \
            --with-system-ciphers \
            --with-pcre-regex \
            --with-zlib \
            --with-layout=GNU \
            --with-kerberos \
            --with-libxml-dir=/usr \
            --with-mhash \
            --enable-dtrace \
            --enable-pcntl \
            --enable-opcache \
            --enable-phpdbg \
            --with-imap=shared --with-imap-ssl \
            --enable-mbstring=shared \
            --enable-mbregex \
            --with-gd=shared \
            --with-gmp=shared \
            --enable-calendar=shared \
            --enable-bcmath=shared \
            --with-bz2=shared \
            --enable-ctype=shared \
            --enable-dba=shared --with-db4=/usr --with-tcadb=/usr \
            --enable-exif=shared \
            --enable-ftp=shared \
            --with-gettext=shared \
            --with-iconv=shared \
            --enable-sockets=shared \
            --enable-tokenizer=shared \
            --with-xmlrpc=shared \
            --with-ldap=shared --with-ldap-sasl \
            --enable-mysqlnd=shared \
            --with-mysqli=shared,mysqlnd \
            --with-mysql-sock=/var/lib/mysql/mysql.sock \
            --enable-dom=shared \
            --with-pgsql=shared \
            --enable-simplexml=shared \
            --enable-xml=shared \
            --enable-wddx=shared \
            --with-snmp=shared,/usr \
            --enable-soap=shared \
            --with-xsl=shared,/usr \
            --enable-xmlreader=shared --enable-xmlwriter=shared \
            --with-curl=shared,/usr \
            --enable-pdo=shared \
            --with-pdo-odbc=shared,unixODBC,/usr \
            --with-pdo-mysql=shared,mysqlnd \
            --with-pdo-pgsql=shared,/usr \
            --with-pdo-sqlite=shared,/usr \
            --with-pdo-dblib=shared,/usr \
            --with-sqlite3=shared \
            --with-libzip \
            --without-readline \
            --with-libedit \
            --with-pspell=shared \
            --enable-phar=shared \
            --with-mcrypt=shared,/usr \
            --with-tidy=shared,/usr \
            --enable-sysvmsg=shared --enable-sysvshm=shared --enable-sysvsem=shared \
            --enable-shmop=shared \
            --enable-posix=shared \
            --with-unixODBC=shared,/usr \
            --enable-fileinfo=shared \
            --enable-intl=shared \
            --with-icu-dir=/usr \
            --with-enchant=shared,/usr
            
RUN cd /usr/src/php/php-7.0 \
    && env CFLAGS="-fno-strict-aliasing -Wno-pointer-sign" \
        EXTENSION_DIR="/usr/lib64/php/modules" \
        PEAR_INSTALLDIR="/usr/share/pear" make \
    && make install \
    && rm -rf /usr/lib64/php/modules/*.a \
    && install -m 755 -d $PHP_INI_DIR/php.d \
    && install -m 644 php.ini-development $PHP_INI_DIR/php.ini.dist \
    && cd /usr/src/php/php-7.0/ext/oci8 \
    && phpize \
    && ./configure --with-pic --with-oci8=shared,instantclient,/usr/lib/oracle/12.1/client64/lib \
    && make -j$(nproc) \
    && make install \
    && cd /usr/src/php/php-7.0/ext/pdo_oci \
    && phpize \
    && ./configure --with-pic --with-pdo-oci=shared,instantclient,/usr,12.1 \
    && make -j$(nproc) \
    && make install \
    && { rm -rf /tmp/* || true; } \
    && { rm -rf /usr/src/php/* || true; } \
    && yum -y erase \
        gcc gcc-c++ cpp glibc-headers libmpc libstdc++-devel \
        make patch libtool autoconf automake m4 perl perl-Carp perl-Data-Dumper perl-Encode \
        perl-Exporter perl-File-Path perl-File-Temp perl-Filter perl-Getopt-Long \
        perl-HTTP-Tiny perl-PathTools perl-Pod-Escapes perl-Pod-Perldoc perl-Pod-Simple \
        perl-Pod-Usage perl-Scalar-List-Utils perl-Socket perl-Storable perl-Test-Harness \
        perl-Text-ParseWords perl-Thread-Queue perl-Time-HiRes perl-Time-Local perl-constant \
        perl-libs perl-macros perl-parent perl-podlators perl-threads perl-threads-shared \
        systemtap-sdt-devel openssl-devel keyutils-libs-devel krb5-devel libcom_err-devel libselinux-devel \
        libsepol-devel libverto-devel pcre-devel \
        bzip2-devel libcurl-devel \
        tokyocabinet-devel enchant-devel libvpx-devel libjpeg-turbo-devel \
        libpng-devel libXpm-devel libX11-devel libXau-devel libxcb-devel xorg-x11-proto-devel \
        freetype-devel t1lib-devel gmp-devel libc-client-devel libicu-devel \
        openldap-devel libmcrypt-devel  freetds-devel \
        unixODBC-devel postgresql-devel sqlite-devel aspell-devel \
        libedit-devel net-snmp-devel elfutils-devel elfutils-libelf-devel lm_sensors-devel \
        perl-devel popt-devel rpm-devel tcp_wrappers-devel libtidy-devel libxslt-devel \
        libgcrypt-devel libgpg-error-devel    

COPY php.ini $PHP_INI_DIR/php.ini
COPY httpd.conf $APACHE_CONF_DIR/conf/

COPY centos-ext-ini-install.sh /usr/src/php/centos-ext-ini-install.sh
RUN for __ext in pgsql odbc ldap snmp xmlrpc imap \
            mysqlnd mysqli pdo_mysql \
            mbstring gd dom xsl soap bcmath dba xmlreader xmlwriter \
            simplexml bz2 calendar ctype exif ftp gettext gmp iconv \
            sockets tokenizer opcache \
            pdo pdo_pgsql pdo_odbc pdo_sqlite pdo_oci \
            zip \
            interbase pdo_firebird \
            sqlite3 oci8 \
            enchant phar fileinfo intl \
            mcrypt tidy pdo_dblib pspell curl wddx \
            posix shmop sysvshm sysvsem sysvmsg recode xml \
        ; do \
        bash /usr/src/php/centos-ext-ini-install.sh ${__ext} /usr/lib64/php/modules $PHP_INI_DIR/php.d; \
        done \
    && install -m 750 -o apache -d /var/lib/php/{session,wsdlcache}

RUN { curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer.phar; } \
    && { ln -s /usr/local/bin/composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer.phar; } \
    && curl -o /tmp/phpunit.phar -SL "https://phar.phpunit.de/phpunit-alpha.phar" \
    && chmod +x /tmp/phpunit.phar \
    && mv /tmp/phpunit.phar /usr/local/bin/phpunit.phar \
    && ln -s /usr/local/bin/phpunit.phar /usr/local/bin/phpunit \
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
    && ln -s /usr/local/bin/behat.phar /usr/local/bin/behat \
    && curl -o /tmp/phpab.phar -sSL "https://github.com/theseer/Autoload/releases/download/1.20.0/phpab-1.20.0.phar" \
    && chmod +x /tmp/phpab.phar \
    && mv /tmp/phpab.phar /usr/local/bin \
    && ln -s /usr/local/bin/phpab.phar /usr/local/bin/phpab


RUN { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
    && yum clean all && { rm -rf /var/cache/yum/* || true; } \
    && mkdir -p /var/spool/xdebug/{profiler,trace} && chown -R apache:apache /var/spool/xdebug \
    && { rm $APACHE_CONF_DIR/conf.d/* $APACHE_CONF_DIR/conf.modules.d/* ${APACHE_CONF_DIR}/sites/* || true; }

COPY vhost.template $APACHE_CONF_DIR/sites/

WORKDIR /var/www/html

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

CMD ["httpd"]
