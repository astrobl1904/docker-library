# Development environment for sites with PHP running as Apache module.
# See the full README for all modules and settings.
# 
# Dockerfile based on the file of the official PHP container.

FROM centos:centos7
MAINTAINER Andreas Strobl <astroblx@asgraphics.at>

ENV PHP_VERSION=5.6.9 \
    PHP_INI_DIR=/etc \
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

