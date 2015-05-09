#!/usr/bin/env bash
set -e

if [ "$1" = 'httpd' ]; then
    
    shift
    
    
    if [ $# -ge 1 ]; then
        
        declare -a args
        args=("$@")
        servername=$(hostname)
        
        # Update Apache config ServerName directive
        if [ -n "$(grep '{{NET_HOSTNAME}}' ${APACHE_CONF_DIR}/conf/httpd.conf)" ]; then
            sed -ri "s/\{\{NET_HOSTNAME\}\}/${servername}/g" "${APACHE_CONF_DIR}/conf/httpd.conf"
        fi
        
        # Create site config files and document root directory
        for ((i = 0; i < ${#args[@]}; i++)); do
            
            site="${args[$i]}"
            ipaddr="$(ifconfig eth0 | grep 'inet addr' | sed -r 's/\s*inet addr:([^ ]+).*/\1/')"
            if [ ! -f "${APACHE_CONF_DIR}/sites/${site}.conf" ]; then
                
                cp "${APACHE_CONF_DIR}/sites/vhost.template" "${APACHE_CONF_DIR}/sites/${site}.conf"
                sed -ri "s/\{\{NET_IPADDR\}\}/${ipaddr}/g" "${APACHE_CONF_DIR}/sites/${site}.conf"
                sed -ri "s/\{\{NET_FQDN\}\}/${site}/g" "${APACHE_CONF_DIR}/sites/${site}.conf"
                
                if [ ! -d "/var/www/${site}" ]; then
                    mkdir -p /var/www/${site}
                fi
            fi
            
        done
        
    fi
    
    exec httpd -D FOREGROUND
    
fi

exec "$@"
