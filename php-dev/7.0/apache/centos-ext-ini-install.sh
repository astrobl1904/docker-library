#!/usr/bin/env bash
set -e
# Generate files lists and stub .ini files for each php extension
__ext="$1"
__verifiedSourcePath="$2"
__destinationPath="$3"

if [ -f ${__verifiedSourcePath}/${__ext}.so ]; then
    case ${__ext} in
        opcache|xdebug)
            # Zend extensions
            ini=10-${__ext}.ini
            param="zend_extension"
            ;;

        pdo_*|mysql|mysqli|wddx|xmlreader|xmlrpc)
            # Extensions with dependencies on 20-*
            ini=30-${__ext}.ini
            param="extension"
            ;;

        *)
            # Extensions with no dependency
            ini=20-${__ext}.ini
            param="extension"
            ;;
    esac
    cat > ${__destinationPath}/${ini} <<__EOF
; Enable $1 extension module
${param}=${__ext}.so
__EOF

fi

case ${__ext} in
    xdebug)
        cat >>${__destinationPath}/${ini} <<__XDEBUG_EOF
[${__ext}]
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1
xdebug.profiler_enable_trigger = 1
xdebug.profiler_output_dir = "/var/spool/xdebug/profiler
xdebug.trace_output_dir = "/var/spool/xdebug/trace
__XDEBUG_EOF
        ;;
esac
