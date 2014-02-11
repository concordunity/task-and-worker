#!/usr/bin/env python                                                               

from celery import Celery
from celery import chord
from celery import group
import time
import os
import subprocess
celery = Celery('dms_tasks',
                broker='amqp://admin:admin@taskserver//',
                result_backend='redis://taskserver:6379/0')

@celery.task(name='process-directory')
def process_dir(n, passwd, path):
   """
   Args: path - the full file path of the directory
   """
   print "Processnig process_dir %d %s %s" % (n, passwd, path)

   txt_filename = os.path.basename(path)

   print txt_filename
   
   txt_filepath = os.path.join('/dmsdocs/datastore', txt_filename)

   print txt_filepath

   txt_filenamebase = os.path.splitext(txt_filename)[0]

   zipdir = os.path.join('/dmsdocs/datastore', txt_filenamebase)

   print "zip dir is :" + zipdir

   zip_files = [f for f in os.listdir(zipdir) if f.endswith('.zip')]
   
   rs = chord(encrypt_zipfile.si(
           n, passwd, zipdir, z) for z in zip_files)(upload_all_files.s(zipdir))
   #rs.get()

@celery.task
def encrypt_zipfile(n, passwd, zipdir, zipfile):
    cmd = os.environ['HOME'] + '/dms/bin/encrypt_one_zip.sh %s %s %d %s' % (
       zipdir, zipfile, n, passwd)
    print "Processing zip file ", cmd 

    # Call the shell script to encrypt one file.   
    DEVNULL=open(os.devnull, 'wb')                                
    subprocess.call(cmd, shell=True, stdout=DEVNULL, stderr=subprocess.STDOUT)
                                                    


@celery.task
def upload_all_files(res, zipdir):
    print "**********************Uploading file to .... ", zipdir 
    cmd = os.environ['HOME'] + '/dms/bin/upload_all_files_in_dir.sh ' + zipdir

    print "upload zip file ", cmd 

    # Call the shell script to encrypt one file.   
    DEVNULL=open(os.devnull, 'wb')                                
    #subprocess.call(cmd, shell=True, stdout=DEVNULL, stderr=devnull)
    p =  subprocess.Popen(os.environ['HOME'] + '/dms/bin/upload_all_files_in_dir.sh ' + zipdir,
                     shell=True, stdout=DEVNULL)
    p.wait()

    print "**********Uploading file over .... "

                                                   

@celery.task
def decrypt_doc(proxy_server, docid):
   try:
      return subprocess.check_output(os.environ['HOME'] + '/dms/bin/get_doc_from_swift.sh ' +
                                     proxy_server + ' ' + docid,
                                     shell=True)
   except subprocess.CalledProcessError:
      return "Failed to exec decrypt program"

@celery.task(queue="doc_decrypt")
def post_process_doc(destdir, docid):
   subprocess.call("touch " + os.environ['HOME']+"/lsong.test",shell=True)
   subprocess.call(os.environ['HOME'] + '/dms/bin/post_process_document.sh ' +
                   destdir + ' ' + docid,
                   shell=True)
