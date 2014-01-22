#!/bin/bash
#
# author: Weidong Shao
# 
# This script processes the necessary document information after a document
# is successfully decrypted.

# It takes two arguments: DIR and DOCID.
# DIR is the directory is where the document files are extracted. 
# DOCID is the 19-digit

cd $1/$2
DOCID=$2

# Make thumbnails
mkdir thumb
	
for f in `ls *.jpg`; do /usr/bin/convert -thumbnail 30% $f thumb/t_$f; done

# Make PDF
mkdir ../wm

COLORA='#30303030'
COLORB='#1c1c1c1c'	
FONT=WenQuanYi-Zen-Hei-Regular
TEXT="存量单证电子档案管理系统"

for f in `ls *.jpg`; do
  convert -size 700x600 xc:none -font AvantGarde-Demi -strokewidth 4 \
         -pointsize 180 -stroke "$COLORB" -fill none  -gravity NorthWest \
         -annotate 45x45+45+15 'COPY'  miff:- | composite -tile - $f ../wm/wm_$f

  convert ../wm/wm_$f -font $FONT -pointsize 128 -fill "$COLORA" \
      -gravity center -annotate -55 "$TEXT" ../wm/wm2_$f
done

rm -rf ../wm/wm_*.jpg
#x=`ls ../wm/wm2_*.jpg | head -80`
#convert $x ../wm_$DOCID.pdf

cd ../wm
for f in `ls wm2_*.jpg`; do
  #echo "About to convert one jpg $f"
  gs -sDEVICE=pdfwrite -o $f.pdf /usr/share/ghostscript/9.05/lib/viewjpeg.ps -c  \($f\) viewJPEG > /dev/null
done
rm -f wm2_*.jpg
#echo "Handling final PDF"
x=`ls *.pdf | head -80`
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=../wm_$DOCID.pdf $x
