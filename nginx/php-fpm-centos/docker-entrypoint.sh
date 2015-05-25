#!/usr/bin/env bash
set -e

if [ "$1" = 'nginx' ]; then

    shift

    servername="$(cat /etc/hostname)"

    if [ $# -eq 0 ]; then
        
        # Create default site
        cat << __END_OF_DEFAULT_SITE_CONF__ > "${NGINX_CONF_DIR}/sites/default-site.conf"
# default server
server {
    listen       80 default_server;
    server_name  localhost;
    root         /usr/share/nginx/html;

    include /etc/nginx/default.d/*.conf;

    location / {
    }

    error_page  404              /404.html;
    location = /40x.html {
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
    }
}

__END_OF_DEFAULT_SITE_CONF__
        
    else

        declare -a args
        args=("$@")

        # Create site config files and document root directory
        for ((i = 0; i < ${#args[@]}; i++)); do

            site="${args[$i]}"
            if [ ! -f "${NGINX_CONF_DIR}/sites/${site}.conf" ]; then

                cp "${NGINX_CONF_DIR}/sites/nginx-site.template" "${NGINX_CONF_DIR}/sites/${site}.conf"
                sed -ri "s/\{\{NET_FQDN\}\}/${site}/g" "${NGINX_CONF_DIR}/sites/${site}.conf"

                if [ ! -d "/var/www/${site}" ]; then
                    mkdir -p /var/www/${site}
                fi
            fi

        done

    fi

    exec nginx

fi

exec "$@"
