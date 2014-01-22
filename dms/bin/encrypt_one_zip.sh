#!/bin/bash

# This program takes 4 arguments
#    directory_of_zip zipfilename index_of_password password 


TMPDIR="/tmp/doc_$$"

mkdir -p $TMPDIR


zipfullpath="$1/$2"

filename=$2
prefix=${filename:0:1}

folder="${filename%_*}"
docidzip="${filename##*_}"
docid="${docidzip%.*}"
bucket=${docid:0:9}
swiftfile=$docid

# Need to create the directory for the bucket
mkdir -p $1/$bucket

cd $TMPDIR
unzip $zipfullpath

touch "key$3"


if [ "$prefix" == "A" ]; then
    bucket="Append-$bucket"
    swiftfile="${folder}_$docid"
fi 

/usr/bin/7za a -m0=bzip2 -p$4 $1/$bucket/$swiftfile.7z . 2>&1 > /dev/null

cd /tmp; /bin/rm -rf $TMPDIR

unlink $zipfullpath
