#!/bin/bash
source $HOME/.bashrc
(perl $TIGGE_TOOLS/ftpprdPullAll.pl); 1>$home/crontab/logs/launch_ftpprdPullAll.log 2>&1 &
exit
