
from dms_tasks import post_process_doc

def dms_get(query):
   docid = query['docid'][0]
   dest = query['dir'][0]
   res = post_process_doc.async_apply(dest, docid, queue="decrypt");
   return { "success" : "ok",
            "value" : 7 }
   #return res.get()
