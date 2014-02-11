#!/bin/bash

#TODO: add error checking.

ZIPDIR=$1
cd $ZIPDIR

PROXY_SERVER1="dms-proxy1"
PROXY_SERVER2="dms-proxy2"

#echo $f >> ~/ddf.txt
for f in `ls`; do
    if [ -d $ZIPDIR/$f ]; then
	cd $ZIPDIR/$f
	echo "upload 7z files $f"

	# upload all files.
	result1=$(swift -A https://$PROXY_SERVER1/auth/v1.0 -U test:tester -K testing upload $f *.7z 2>&1 > /dev/null)

	# check if the result is empty.
	#echo $result1
	#if [ -z "$result" ]; then
	        #echo "we need to check and remove selected files"
	#        cd ..
        #    echo "Clean up 7z files"
	#        rm -rf $ZIPDIR/$f
	#	fi
	# upload all files.
	#result2=$(swift -A https://$PROXY_SERVER2/auth/v1.0 -U test:tester -K testing upload $f *.7z 2>&1 > /dev/null)

	# check if the result is empty.
	#echo $result2
	#if [ -z "$result1" -a -z "$result2" ]; then
	if [ -z "$result1" ]; then
	    #echo "we need to check and remove selected files"
	    cd $ZIPDIR
            echo "Clean up 7z files"
	    rm -rf $ZIPDIR/$f
	fi
    fi
done

#move zip to offline backup


#ARCHIVE_DIR=/dmsdocs/archive/$(date +%Y%m%d)
#ARCHIVEDEST=$ARCHIVE_DIR/$(basename $ZIPDIR)
#mkdir -p $ARCHIVEDEST
#mv $ZIPDIR/*.zip $ARChiveDEST/.

if [ -z "$(ls $ZIPDIR)" ]; then
    echo "removing directory is empty"
    rm -rf $ZIPDIR
fi

unlink ${ZIPDIR}.txt
