#!/usr/bin/env bash
set -e

if [ "$1" = 'httpd' ]; then

    shift

    servername="$(cat /etc/hostname)"
    ipaddr="$(ip -family inet address show dev eth0 | grep 'inet' | sed -r 's/\s*inet ([^\/]+).*/\1/')"

    # Update Apache config ServerName directive
    if [ -n "$(grep '{{ *NET_HOSTNAME *}}' ${APACHE_CONF_DIR}/conf/httpd.conf)" ]; then
        sed -ri "s/\{\{ *NET_HOSTNAME *\}\}/${servername}/g" "${APACHE_CONF_DIR}/conf/httpd.conf"
    fi

    if [ $# -ge 1 ]; then

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
                    
                    sed -ri "s/\{\{ *${_key} *\}\}/${_value}/g" "${APACHE_CONF_DIR}/sites/${site}.conf"
                    
                fi

            else

                # Create new site config
                if [ -n "${site}" ]; then
                    sed -ri "/\{\{[^\}]+\}\}/d" "${APACHE_CONF_DIR}/sites/${site}.conf"
                fi
                
                site="${args[$i]}"
                if [ ! -f "${APACHE_CONF_DIR}/sites/${site}.conf" ]; then
                    
                    cp "${APACHE_CONF_DIR}/sites/vhost.template" "${APACHE_CONF_DIR}/sites/${site}.conf"
                    sed -ri "s/\{\{ *NET_IPADDR *\}\}/${ipaddr}/g" "${APACHE_CONF_DIR}/sites/${site}.conf"
                    sed -ri "s/\{\{ *NET_FQDN *\}\}/${site}/g" "${APACHE_CONF_DIR}/sites/${site}.conf"
                    
                    if [ ! -d "/var/www/${site}" ]; then
                        mkdir -p /var/www/${site}
                    fi
                fi

            fi

        done
        
        # Cleanup last site config
        if [ -n "${site}" ]; then
            sed -ri "/\{\{[^\}]+\}\}/d" "${APACHE_CONF_DIR}/sites/${site}.conf"
        fi

    fi

    exec httpd -D FOREGROUND

fi

exec "$@"
