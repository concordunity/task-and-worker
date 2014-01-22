#!/bin/bash

#Lsong
#i@lsong.org
#https://lsong.org

LOG=$PWD/worker.log

cd $HOME/dms/bin/

nohup celery -A dms_tasks worker --config=c --concurrency=7 > $LOG 2>&1 &

echo "worker now running, see more information in $LOG ."
