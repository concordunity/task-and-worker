#!/usr/bin/env python
# -*- coding: utf-8 -*

import json
import os
import re

from cgi import parse_qs, escape

from dms_tasks import decrypt_doc
from dms import mibs
from mibs import docs, quitquitquit, postdoc

class ApiServer(object):
    """
    Handles all web service requests from the host EMS. 
    """
    def __init__(self):
        self._postData = None
        self._method = 'GET'

    def __call__(self, environ, start_response):
        self._method = environ['REQUEST_METHOD']
        path = environ['PATH_INFO']
        
        has_error = False
        method_name = "dms_get"
        resource = path.lstrip('/')
        self._post_data = parse_qs(environ['QUERY_STRING'])

        try:
            print "trying to get module ", resource
                #print dir(mibs.nodeinfo)
            #print mibs.__name__

            mod_resource = getattr(mibs, resource)
            impl = getattr(mod_resource, method_name)

            attrs = impl(self._post_data)
            if attrs is None:
                has_error = True
                error_message = 'The device responded with error.'
        except AttributeError as r:
            print r
            has_error = True
            error_message = 'The API is not implemented'


        # Dispatch request to different methods.
        if has_error:
            attrs = { "error" : error_message }

        response_body = json.dumps(attrs)            



        response_header = [('Content-Type', "application/json"),
                           ('Content-Length', str(len(response_body)))]
        response_header = [('Content-Type', "application/json"),
                           ('Content-Length', str(len(response_body)))]  
        
        start_response('200 OK', response_header)
        return [response_body]

