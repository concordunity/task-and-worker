#!/bin/bash

#Lsong
#i@lsong.org
#https://lsong.org

#LOG=/dev/null
LOG=taskserver.log

>$LOG

APP=$HOME/dms/bin/uploading_watcher.py

nohup python $APP > $LOG 2>&1 & #run in background .

echo "taskserver now running, see more information in $LOG"

