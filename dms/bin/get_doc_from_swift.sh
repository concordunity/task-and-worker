#!/bin/bash

# This program takes either of the following:
#  a) two arguments: the proxy server docid, which is the 18-digit number.
#  b) two arguments: the proxy server, docid, a folder name that starts with A



PASSWD_FILE=$HOME/bin/conf/passwd.txt
PROXY_SERVER=$1
docid=$2


print_argument_error() {
    echo "Program Error: invalid arguments"
    exit 1
}

print_error_response() {
    echo "The requested document is not found"
}

print_json_response() {
    # the first argument is the JSON file.
    cat $1
}

send_response() {
    JSON="$TMPDIR/$docid/$docid.json"
    if [ -f $JSON ]; then
      print_json_response $JSON
      exit 0
    fi

    print_error_respones
    exit 1
}

get_modified_document() {    
    folder=$1
    bucket="Append-${docid:0:9}"
    TMPDIR="/dmsdocs/public/docimages_mod/${folder}_$docid"

    fetch_and_decrypt $TMPDIR $bucket "${folder}_$docid.7z"
}

get_document() {
    bucket=${docid:0:9}
    TMPDIR="/dmsdocs/public/docimages/$docid"
    #echo "calling fetch_and_decrypt $TMPDIR $bucket $docid    "
    fetch_and_decrypt $TMPDIR $bucket "$docid.7z"
}

fetch_and_decrypt() {
    # $1 is the base directory to put the file into
    # $2 is the bucket id
    # $3 is the filename 

    DESTDIR=$1

    if [ -d "$DESTDIR" ]; then
	JSON="$DESTDIR/$docid/$docid.json"
        if [ -f "$JSON" ]; then
	    print_json_response $JSON
	    exit 0
        else
	    echo "System busy."
	    exit 1
	fi
    fi

    mkdir -p $DESTDIR
    cd $DESTDIR

    swift -A https://$PROXY_SERVER/auth/v1.0 -U test:tester -K testing download -o t.7z $2 $3  > /dev/null 2>&1

    if [ -f "$TMPDIR/t.7z" ]; then
	result=`/usr/bin/7z l t.7z -so 2>&1 | perl -n -e '/key(\d+)/ && print $1'`
	line=`expr $result + 1`
	#echo $result
	#echo "Line $line"

	pass=$(sed "${line}q;d" $PASSWD_FILE)
	#echo $pass
	#echo "$pass is here"
	/usr/bin/7z x -y -p$pass t.7z > /dev/null
	print_json_response $DESTDIR/$docid/$docid.json

	# Now, process the file
	#curl "http://localhost:8090/process_doc?docid=$docid&dir=$DESTDIR" > /dev/null 2>&1
	#$HOME/bin/post_process_document.sh $DESTDIR $docid &
    else
	print_error_response
	rm -f $DESTDIR
    fi    
}


if [ $# -eq 3 ]; then
    get_document
else
    get_modified_document $3
fi
