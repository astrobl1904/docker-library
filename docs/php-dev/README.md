# About this Repo

This repo contains another Docker image for the PHP general-purpose scripting language.

It is based on CentOS Linux and contains the Oracle `oci8` and the
`Xdebug`\*) modules. For PDF support PDFlib's proprietary `PDFlib`\*) module is
included.

# Supported tags and respective `Dockerfile`

- [`5.3-apache-centos6`, `5.3.3-apache-centos6` (*5.3/apache/Dockerfile*)](https://github.com/astrobl1904/docker-library/tree/master/php-dev/5.3/apache/Dockerfile)
- [`latest`, `apache-centos`, `5-apache-centos`, `5.6-apache-centos`, `5.6.12-apache-centos` (*5.6/apache/Dockerfile*)](https://github.com/astrobl1904/docker-library/tree/master/php-dev/5.6/apache/Dockerfile)
- [`fpm-centos`, `5-fpm-centos`, `5.6-fpm-centos`, `5.6.12-fpm-centos` (*5.6/fpm/Dockerfile*)](https://github.com/astrobl1904/docker-library/tree/master/php-dev/5.6/fpm/Dockerfile)
- [`7beta-apache-centos`, `7.0beta-apache-centos`, `7.0.0beta3-apache-centos` (*7.0/apache/Dockerfile*)](https://github.com/astrobl1904/docker-library/tree/master/php-dev/7.0/apache/Dockerfile)
- [`7beta-fpm-centos`, `7.0beta-fpm-centos`, `7.0.0beta3-fpm-centos` (*7.0/fpm/Dockerfile*)](https://github.com/astrobl1904/docker-library/tree/master/php-dev/7.0/fpm/Dockerfile)

# What is PHP

PHP is a popular general-purpose scripting language that is especially suited to web development.
Fast, flexible and pragmatic, PHP powers everything from your blog to the most popular websites in the world.

Instead of lots of commands to output HTML (as seen in C or Perl), PHP pages contain HTML with embedded code that does "something" (in this case, output "Hi, I'm a PHP script!"). The PHP code is enclosed in special start and end processing instructions <?php and ?> that allow you to jump into and out of "PHP mode."

What distinguishes PHP from something like client-side JavaScript is that the code is executed on the server, generating HTML which is then sent to the client. The client would receive the results of running that script, but would not know what the underlying code was. You can even configure your web server to process all your HTML files with PHP, and then there's really no way that users can tell what you have up your sleeve.

The best things in using PHP are that it is extremely simple for a newcomer, but offers many advanced features for a professional programmer. Don't be afraid reading the long list of PHP's features. You can jump in, in a short time, and start writing simple scripts in a few hours.

Although PHP's development is focused on server-side scripting, you can do much more with it.

PHP has useful text processing features, which includes the Perl compatible regular expressions (PCRE), and many extensions and tools to parse and access XML documents. PHP standardizes all of the XML extensions on the solid base of libxml2, and extends the feature set adding SimpleXML, XMLReader and XMLWriter support.

And many other interesting extensions exist, which are categorized both alphabetically and by category. And there are additional PECL extensions that may or may not be documented within the PHP manual itself, like XDebug.

> [wikipedia-org/wiki/PHP](http://en.wikipedia.org/wiki/PHP)  
![logo](http://php.net/images/logos/php-med-trans.png)

## Included Modules

The following PHP modules are included with this Docker image:

> php\_bcmath, php\_gd, php\_ldap, php\_mbstring, php\_mysql, php\_pgsql, php\_pdo, php\_soap, php\_xml, php\_devel, php\_opcache, php\_pear, 
> xdebug\*), oci8 (Instant Client 12.1.0.2), php\_pdflib\*) (9.0.3)

## Included Code Quality Tools ##

In releases 5.6.10 and forthgoing the following code quality tools are included and can be run interactively in a container

> phpunit (PHPUnit), de-legacy-fy (PHP De-Legacyfyer), behat (Behat), phploc (PHPLoc), pdepend (PHP\_Depend), phpmd (PHP Mess Detector),
> phpcs (PHP\_CodeSniffer), phpcpd (PHP Copy/Paste Detector), phpdcd (PHP Dead Code Detector), hhvm-wrapper, phpdox (phpDox)  
> Additionally: phpab [PHP Autoload Builder](https://github.com/theseer/Autoload) by TheSeer

For more information please visit [The PHP Quality Assurance Toolchain](http://phpqatools.org)

## Config File Paths

- PHP: /etc, /etc/php.d
- Apache: /etc/httpd/conf
- Oracle Instantclient: /etc
- PDFlib\*): /usr/local/PDFlib/

## Xdebug Configuration

Xdebug remote debugging is enabled and with `remote_connect_back` turned on. 
Xdebug uses the standard port tcp/9000 to connect to the debugging client. 
Additionally the profiler can be triggered with the GET/POST variable 
`XDEBUG_PROFILE`. Trace and profile files are stored in the directories
`profiler` and `trace` in the directory `/var/spool/xdebug`.
## Apache Logs

Apache logs are kept in `/var/log/httpd/`. Logs for sites are saved in a 
folder in the log directory. The folder is named after the server's name.

# How to use this image

This image contains the major database modules, the PDFlib module and the Xdebug module.

## Start a PHP Apache default instance

    docker run --name www-default -d astrobl1904/php-dev
    
This image includes `EXPOSE 80` (the default HTTP port)

## Start a PHP FastCGI container

    docker run --name php-fpm-backend -d astrobl1904/php-dev:5.6-fpm-centos
    
This image includes `EXPOSE 9000`. If linked to a web server container make sure both container use the same documents root. For more information see

- [Managing data in containers](https://docs.docker.com/userguide/dockervolumes/#volume)
- [Linking Container Together](https://docs.docker.com/userguide/dockerlinks/)

You might try the `astrobl1904/nginx` image which supports linking of a container using the `astrobl1904/php-dev:5.6-fpm-centos` image. All images described here are based on Docker's public library image `CentOS`.

## Environment Variables

The PHP image contains various database modules. The Oracle `oci8` module requires the default Oracle variables to be set. Without any option the following variables are used

### TNS_ADMIN

This environment variable is set to the `/etc` directory which contains the `tnsnames.ora` file. This file is a placeholder file and must be mounted if you plan to use the `oci8` module.

### NLS_LANG

This environment variable must be set in order to use the `oci8` module. The default value use the german language with the iso-8859-1 characterset. Default value: `GERMAN_AUSTRIA.WE8ISO8859P1`.

# How to extend this image

> If you want to create a certain Apache vhost, you may do so with providing an argument to the httpd command. This creates a `DocumentRoot` under `/var/www/` with the provided servername. You can either mount a local directory into this mount point or mount a volume from another Docker container. After the FQDN you can provide additional key-value pairs that will be substituted in the vhost template (in case you mounted your own template).
> [Managing data in containers](https://docs.docker.com/userguide/dockervolumes/#volume).

    docker run -name www-myserver -v /your/document/root:/var/www/myserver.domain.tld -d astrobl1904/php-dev httpd myserver.domain.tld [[key=value] [key2=value]...]

## Build Dependencies

In order to build this image the Oracle Instant Client RPMs for Red Hat distributions must be downloaded and put into the directory where the Dockerfile is located. The name of the RPMs must be

- `oracle-instantclient.x86_64.rpm`
- `oracle-instantclient-devel.x86_64.rpm`

Additionally the proper path to the installed Oracle libraries must be updated in the ld.so loader config file `oracle-instantclient.x86_64.conf`.

# Supported Docker versions

This image is supported on Docker version 1.6.2.

Support for older versions (down to 1.0) is provided on a best-effort basis.

---
\*) These PHP modules are currently not available for PHP 7.