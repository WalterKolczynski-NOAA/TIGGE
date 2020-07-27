# .bashrc

# User specific aliases and functions

export home="/home/nomads"

alias lls="ls -lrS"
alias dum="du -smc "
alias psu="ps -fu nomads"
alias dfm="df -m "
alias grads2="/usr/local/grads/grads-2.0.1/bin/grads"

# System Variables and paths

export NEXUS="/global/dataset/model"
#
# NEXUS Relative
export NEXUSDIR="$NEXUS"
export NOMADS_CONFIG="$NEXUS/config"
#
# Toolkits
export CRONTAB_LOGS="$home/crontab/logs"
export LOG_DIRS="$CRONTAB_LOGS"
export ADMIN_LOGS="$home/adminLogs"
#  yes-- SRRS_TOOLS is strange but not incorrect
#
# java
export JAVA="/usr/bin/java"
export JAVA_HOME="/usr/local/j2sdk1.4.2_08"
export JAVA_OPTS="-Xmx1024m"
#



#	Version Controllers
export SVNROOT="https://conman.ncdc.noaa.gov/svn-repos/nomads"
export SVN_EDITOR="vi"



#   TIGGE Process
export TIGGE_TOOLS="/raid/nomads/tigge/rerun"
export TIGGE_OUTPUT="$TIGGE_TOOLS/output"
export TIGGE_INPUT="$TIGGE_TOOLS/input"
#        GRIB_DEFINITION_PATH and SAMPLES need to be set to the location of an installation
#          location of grib_api
#          that is compatable with the operational TIGGE code base
#   failure to do so will result in grib_api key related run-time errors.
#      If there is only one installation of GRIB_API on system, this may be ignorable.
export GRIB_DEFINITION_PATH="$home/grib_api-1.13.0/share/grib_api/definitions"
export GRIB_SAMPLES_PATH="$home/grib_api-1.13.0/share/grib_api/samples"
export PERL5LIB="$TIGGE_TOOLS/perl-lib"




###	UNIDATA PACKAGES
export UDUNITS_PATH="/usr/local/udunits-1.12.4/etc/udunits.dat"


# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi


#	Set the program search path

export PATH="/bin:$TIGGE_TOOLS/grib-api:$TIGGE_TOOLS/grib-api/bin:/usr/bin:/usr/local/bin:/usr/bin/X11:/usr/accs:/usr/new:/usr/etc:/usr/openwin/bin:/usr/local/decoders-3.0.6/bin/:/usr/local/udunits-1.12.4/bin/:/usr/local/netcdf-3.6.0/bin/:$home/cron_jobs:/usr/local/degrib/bin:$home/bin"

PS1='\h:$PWD $ '
export PS1

#Do not remove the following line or set the SHELL to anything else
export SHELL=/usr/local/bin/bash
