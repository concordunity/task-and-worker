#!/bin/bash

#Lsong
#i@lsong.org
#https://lsong.org

#SOURCE=.
SOURCE=pkg
#DEST=/tmp
DEST=`pwd`
#LOG=/dev/null
LOG=$DEST/install.log

#clear already log .
> $LOG

for filename in `cat manifest.list` 
do
  filename=$SOURCE/$filename
  tar xzf $filename -C $DEST
  PKG=`basename $filename .tar.gz`
  echo "Install : $PKG"
  cd $DEST/$PKG
  sudo python setup.py install > $LOG 2>&1
  sudo rm -rf $DEST/$PKG
  cd - > /dev/null
done
echo "Take a few minute .."
sudo apt-get update >> $LOG 2>&1
echo "Install : nfs-common"
sudo apt-get -y install nfs-common >> $LOG 2>&1
echo "Install : p7zip-full"
sudo apt-get -y install p7zip-full >> $LOG 2>&1
echo "Install : unzip"
sudo apt-get -y install unzip >> $LOG 2>&1


echo "Install done, see more information in $LOG"
