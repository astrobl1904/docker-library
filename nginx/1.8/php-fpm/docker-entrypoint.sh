#!/usr/bin/env bash
set -e

# Updates the backend settings if a php-fpm container is linked
# to this container
function updatePhpFpmBackend() {
    
    local _backendServer="${PHP_FPM_BACKEND_SERVER}"
    local _backendConfig="${NGINX_CONF_DIR}/conf.d/php-fpm-backend.conf"
    
    if [ $# -eq 1 -a -n "$1" ]; then

        local _backendContainer="$(env | grep ${1}_PORT= | cut -d'=' -f2)"
        _backendContainer="$(echo ${_backendContainer} | \
            sed -r 's!^((tcp|udp)://)([0-9]{1,3}(\.[0-9]{1,3}){3}|[0-9a-f:]+)(%[a-z0-9]+)?:([0-9]+).*!\3:\6!' \
        )"
        if [ -n "${_backendContainer}" ]; then
            _backendServer=${_backendContainer}
        fi

    fi
    
    if [ -f "${_backendConfig}" -a -n "${_backendServer}" ]; then

        sed -ri "s!server 127\.0\.0\.1\:[0-9]+!server ${_backendServer}!" "${_backendConfig}"

    fi
}

# Get linked container alias
function linkedContainerAlias() {
    local _linkedContainer="$(env | grep _NAME=/ | cut -d'=' -f2)"
    local _prefix=""
    
    if [ -n "${_linkedContainer}" ]; then

        local _containerName="$(echo ${_linkedContainer} | cut -d'/' -f2)"
        local _containerAlias="$(echo ${_linkedContainer} | cut -d'/' -f3)"
        _prefix="$(echo ${_containerAlias} | tr 'a-z' 'A-Z')"
        
    fi
    
    echo "${_prefix}"
}

# Main
if [ "$1" = 'nginx' ]; then

    shift

    servername="$(cat /etc/hostname)"
    containerAlias="$(linkedContainerAlias)"

    updatePhpFpmBackend "${containerAlias}"

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
        site=""

        # Create site config files and document root directory
        for ((i = 0; i < ${#args[@]}; i++)); do

            # Test for parameter or site
            _arg="${args[$i]}"
            if [[ ${_arg} =~ "=" ]]; then

                # Replace placeholders
                if [ -n "${site}" ]; then

                    _key=$(echo ${_arg} | cut -d= -f1)
                    _value=$(echo ${_arg} | cut -d= -f2-255 | sed -r 's#/#\\\/#g')
                    
                    sed -ri "s/\{\{${_key}\}\}/${_value}/g" "${NGINX_CONF_DIR}/sites/${site}.conf"
                    
                fi

            else

                # Create new site config
                if [ -n "${site}" ]; then
                    sed -ri "/\{\{[^\}]+\}\}/d" "${NGINX_CONF_DIR}/sites/${site}.conf"
                fi

                site="${args[$i]}"
                if [ ! -f "${NGINX_CONF_DIR}/sites/${site}.conf" ]; then

                    cp "${NGINX_CONF_DIR}/sites/nginx-site.template" "${NGINX_CONF_DIR}/sites/${site}.conf"
                    sed -ri "s/\{\{NET_FQDN\}\}/${site}/g" "${NGINX_CONF_DIR}/sites/${site}.conf"

                    if [ ! -d "/var/www/${site}" ]; then
                        mkdir -p /var/www/${site}
                    fi
                fi

            fi

        done

        # Cleanup last site config
        if [ -n "${site}" ]; then
            sed -ri "/\{\{[^\}]+\}\}/d" "${NGINX_CONF_DIR}/sites/${site}.conf"
        fi

    fi

    exec nginx

fi

exec "$@"
