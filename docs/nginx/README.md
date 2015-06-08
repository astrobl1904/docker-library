# About this Repo

This repo contains another nginx Image.

It is based on CentOS Linux and is prepared to use PHP with the PHP FastCGI Process Manager. It is assumed that the backend is listening on port 9000.

# Supported tags and respective `Dockerfile`

- [`1.6-php-fpm-centos`, `1.6.3-php-fpm-centos`, `latest` (*1.6/php-fpm/Dockerfile*)](https://github.com/astrobl1904/docker-library/tree/master/nginx/1.6/php-fpm/Dockerfile)

# What is Nginx?

nginx [engine x] is an HTTP and reverse proxy server, a mail proxy server, and a generic TCP proxy server, originally written by Igor Sysoev.

> [wikipedia-org/wiki/Nginx](https://en.wikipedia.org/wiki/Nginx)  
![logo](http://nginx.org/nginx.png)

## Included Configurations

The image contains the default nginx configuration but with the daemon set to off. For FastCGI support a backend configuration is included. As with the PHP as Apache module the Web server can be customized by running nginx with a site name as additional argument (see the Dockerfile and the How to part of this readme).

The image is based on Docker's public CentOS repository.


## Config File Paths

- Nginx: /etc/nginx
- PHP FPM Backend Config: /etc/nginx/conf.d/php-fpm-backend.conf
- Nginx Server Config template: /etc/nginx/sites/nginx-site.template

## Nginx Logs

Nginx logs are kept in `/var/log/nginx/`. Logs for sites are saved in this 
folder. The log files are prefixed with the FQDN of the server.

# How to use this image

This image contains a configuration for the PHP FastCGI Process Manager daemon. It is triggered by providing a server name after the nginx command.

## Start a Nginx default instance

    docker run --name www-default -d astrobl1904/nginx

This starts the nginx daemon without any modifications and displays only the default 
test site of a freshly setup nginx server.

This image includes `EXPOSE 80` (the default HTTP port)

## Start nginx to use the PHP FPM backend

    docker run --name www-phpfpm -d -P astrobl1904/nginx nginx localhost.localdomain

This image includes `EXPOSE 80`. If linked to a PHP FPM backend container make sure both container use the same documents root. For more information see

- [Managing data in containers](https://docs.docker.com/userguide/dockervolumes/#volume)
- [Linking Container Together](https://docs.docker.com/userguide/dockerlinks/)

You might try the `astrobl1904/php-dev:5.6-fpm-centos` image that provide the PHP FPM backend listening on port 9000. All images described here are based on Docker's public library image `CentOS`.

    docker create -v /var/webdata:/var/www/localhost.localdomain --name webdata centos:centos7 /bin/true
    docker run -d --volumes-from webdata --name php-fpm-backend astrobl1904/php-dev:5.6-fpm-centos
    ocker run -d --volumes-from webdata -p 0.0.0.0:80:80 --link php-fpm-backend:fpm_backend nginx:1.6-php-fpm-centos nginx localhost.localdomain

These commands create a volume container (with /var/webdata mapped into the container), starts a PHP-FPM container named php-fpm-backend and starts the nginx container with linking in the php-fpm-backend container.

## Environment Variables

The nginx image contains an environment variable that allows to set backend server at start time of the container.

### PHP\_FPM\_BACKEND\_SERVER

This environment variable contains the IP address of the backend server followed by the port the server is listening. IP address and port are separated by a colon.


# How to extend this image

> If you want to create a certain Apache-like vhost, you may do so with providing an argument to the `nginx` command. This creates a `DocumentRoot` under `/var/www/` with the provided servername. You can either mount a local directory into this mount point or mount a volume from another Docker container.
> [Managing data in containers](https://docs.docker.com/userguide/dockervolumes/#volume).


# Supported Docker versions

This image is supported on Docker version 1.6.0.

Support for older versions (down to 1.0) is provided on a best-effort basis.

