#!/bin/bash

#Lsong
#i@lsong.org
#https://lsong.org

WORK_DIR=/home/david/dms/bin
#LOG=/dev/null
LOG="$WORK_DIR/taskserver.log"
APP="$WORK_DIR/uploading_watcher.py"

>$LOG


start_taskserver(){
    nohup python $APP > $LOG 2>&1 & #run in background .
    echo "taskserver now running, see more information in $LOG"
}

case "$1" in
    start)
	start_taskserver
    ;;
    *)
	echo "Usage: etc/init.d/taskserver {start}"
	exit 1
    ;;
esac

exit 0

