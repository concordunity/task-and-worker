#!/bin/sh -e
# ============================================
#  celeryd - Starts the Celery worker daemon.
# ============================================
#
# :Usage: /etc/init.d/celeryd {start|stop|restart|status}
#

#Lsong
#i@lsong.org
#https://lsong.org

### BEGIN INIT INFO
# Provides:          celeryd
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop:     $network $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: celery task worker daemon
### END INIT INFO

# some commands work asyncronously, so we'll wait this many seconds
SLEEP_SECONDS=5

CELERY_APP=dms_tasks
CELERY_USER=david
CELERY_BIN=celery
CELERY_CONFIG=c
CELERY_PATH="/home/$CELERY_USER/dms/bin"
CELERY_PID="$CELERY_PATH/celery.pid"
CELERY_LOG="$CELERY_PATH/celery.log"

cd $CELERY_PATH

maybe_die() {
    if [ $? -ne 0 ]; then
        echo "Exiting: $* (errno $?)"
        exit 77  # EX_NOPERM
    fi
}

check_status(){
    if [ -f $CELERY_PID ]; then
	pid=`cat $CELERY_PID`
	kill -0 $pid
	if [ $? -ne 0 ]; then
	    echo "process maybe die ."
	else
	    echo "[$pid] celery is running."
	fi
    else
	echo "not runing."
    fi
}

stop_workers () {
    pid=`cat $CELERY_PID`
    kill -9 $pid
    sleep $SLEEP_SECONDS
}

start_workers () {
    echo "Start [$CELERY_APP] ..."
    sudo -u $CELERY_USER sh -c "$CELERY_BIN -A $CELERY_APP worker --config=$CELERY_CONFIG --logfile=$CELERY_LOG --pidfile=$CELERY_PID > /dev/null 2>&1 &"
    sleep $SLEEP_SECONDS
}

restart_workers () {
    sleep $SLEEP_SECONDS
}

case "$1" in
    start)
        start_workers
    ;;

    stop)
        stop_workers
    ;;

    reload|force-reload)
        echo "Use restart"
    ;;

    status)
        check_status
    ;;

    restart)
        stop_workers
        start_workers
    ;;
    *)
        echo "Usage: /etc/init.d/celeryd {start|stop|restart}"
        exit 64  # EX_USAGE
    ;;
esac

exit 0
