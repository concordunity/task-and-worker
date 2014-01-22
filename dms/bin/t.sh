#!/bin/bash

ZIPDIR=$1
ARCHIVE_DIR=/dmsdocs/archive/$(date +%Y%m%d)
mkdir -p $ARCHIVE_DIR/$(basename $ZIPDIR)
