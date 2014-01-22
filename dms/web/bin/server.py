#!/usr/bin/env python
# -*- coding: utf-8 -*

import cherrypy
import json
import os
import sys

sys.path.append('/home/vagrant/dms/bin')

from dms import api_server
from cgi import parse_qs, escape

#errorlog = open('http-traceback.log', 'a', 0)

class DmsWeb(object):
    """ The object that serves all static files for the web interface."""
    
    @cherrypy.expose
    def index(self):
      raise cherrypy.HTTPRedirect("/dms/index.html", 301)

if __name__ == '__main__':

    # Get the current working directory.
    _curr_dir = os.getcwd()


    cherrypy.config.update({'global' : {
          'server.socket_host' : '0.0.0.0',
          'server.thread_pool' : 10,
          'server.environment' : 'production'
          } })

    application_config = {
        '/favicon.ico' : {
            'tools.staticfile.on' : True,
            'tools.staticfile.filename' :  os.path.join(_curr_dir, '../public/images/favicon.ico') },
        '/' : {
            'tools.staticdir.root' : os.path.join(_curr_dir, '../public')
            }
        }

    # Mount all the static resource directories.
    for dir in ['dms', 'scripts', 'images', 'img' ]:
        application_config['/' + dir] = { 
            'tools.staticdir.on' : True,
            'tools.staticdir.dir' : dir }

    cherrypy.tree.mount(DmsWeb(), '/', config = application_config)
    cherrypy.tree.graft(api_server.ApiServer(), '/api');

    cherrypy.engine.start()
    cherrypy.engine.block()
