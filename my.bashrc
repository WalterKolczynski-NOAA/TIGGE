# .bashrc

# User specific aliases and functions

alias hsi="hsi -l orders"
alias lls="ls -lrS"
alias dum="du -smc "
alias psu="ps -fu nomads"
alias dfm="df -m "
alias nhas="perl /home/nomads/bin/nhas.pl "
alias grads2="/usr/local/grads/grads-2.0.1/bin/grads"

# System Variables and paths

export home="/home/nomads"
export NEXUS="/global/dataset/model"
#
# NEXUS Relative
export NEXUSDIR="$NEXUS"
export LDM_DATA_MERGED="$NEXUS"
export NCEP_HIRES_DIR="$NEXUS"
export NCEP_HIRES_DATA="$NEXUS"
export NCEP_HIRES_TOOLS="$NEXUS"
export NCEP_HIRES_ANALYSIS="$NEXUS"
export GHCN_DIR="$NEXUS/ghcn"
export NARR_DATA="$NEXUS/narr"
export ERSST_DIR="$NEXUS/sst"
export SRRS_DATA="$NEXUS/srrs"
export OISST_DIR="$NEXUS/oisst"
export NCEP_NEW_CHARTS="$NEXUS/ncep_charts/new_charts"
export NCEP_OLD_CHARTS="$NEXUS/ncep_charts/old_charts"
export NOMADS_MERGED_DATA="$NEXUS"
export IGRA_DATA="$NEXUS/igra"
export GDAS_DATA="$NEXUS/gdas"
export LDM_DATA_ROOT="$NEXUS"
export CTL_TEMPLATES="$NEXUS/ctl_templates"
export NOMADS_CONFIG="$NEXUS/config"
#
# Toolkits
export CRONTAB_LOGS="$home/crontab/logs"
export LOG_DIRS="$CRONTAB_LOGS"
export NARR_TOOLS="$home/narr_tools"
export ADMIN_LOGS="$home/adminLogs"
export LDM_TOOLS="$home/ldm_tools"
export NDFD_TOOLS="$home/ndfd_tools"
export GDAS_CGI_BIN="$home/gdas_tools"
export SRRS_TOOLS="$NEXUS/srrs/../bin"
#  yes-- SRRS_TOOLS is strange but not incorrect
export GHCN_TOOLS="$home/ghcn_tools"
export MODEM_TOOLS="$home/modem_tools"
export ERSST_TOOLS="$home/ersst_tools"
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
export TIGGE_TOOLS="$home/tigge"
export TIGGE_OUTPUT="$home/tigge/output"
export TIGGE_INPUT="$home/tigge/input"
#        GRIB_DEFINITION_PATH and SAMPLES need to be set to the location of an installation
#          location of grib_api
#          that is compatable with the operational TIGGE code base
#   failure to do so will result in grib_api key related run-time errors.
#      If there is only one installation of GRIB_API on system, this may be ignorable.
export GRIB_DEFINITION_PATH="$home/grib_api-1.13.0/share/grib_api/definitions"
export GRIB_SAMPLES_PATH="$home/grib_api-1.13.0/share/grib_api/samples"
export PERL5LIB="/usr/local/perl"




###	UNIDATA PACKAGES
export UDUNITS_PATH="/usr/local/udunits-1.12.4/etc/udunits.dat"


# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi


#	Set the program search path

export PATH="./:/bin:$TIGGE_TOOLS/grib-api:$TIGGE_TOOLS/grib-api/bin:/usr/bin:/usr/local/bin:/usr/bin/X11:/usr/accs:/usr/new:/usr/etc:/usr/openwin/bin:/usr/local/decoders-3.0.6/bin/:/usr/local/udunits-1.12.4/bin/:/usr/local/netcdf-3.6.0/bin/:$home/cron_jobs:/usr/local/degrib/bin:$home/bin"

PS1='\h:$PWD $ '
export PS1

#Do not remove the following line or set the SHELL to anything else
export SHELL=/usr/local/bin/bash
