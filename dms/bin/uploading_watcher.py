#!/usr/bin/env python 

import collections
import pyinotify
import random
import os

from dms_tasks import process_dir

__author__ = ' Weidong Shao (weidongshao@gmail.com)'

PasswdInfo = collections.namedtuple('PasswdInfo', ['index', 'passwd'])

# TODO(weidong): Add error handling!!
class KeyInfo(object):
  def __init__(self):
    self._loaded = False

  def load_keys(self, filename):

    """ Load password entries from a text file. Each line is a 20-char
        password string that was initially generated at system installation"""
    f = open(filename, "r")
    self._keys = f.readlines()
    print ' Loading total keys ', len(self._keys)
    f.close()
    self._loaded = True

  def key_loaded(self):
    return self._loaded
  
  def get_key(self, index):
    # Do a sanity check first
    if index < 0 or index >= len(self._keys):
      return ''

    return self._keys[index].rstrip()

  def pick_random_pass(self):
    index = random.randint(0, len(self._keys) -1)
    return PasswdInfo(index, self.get_key(index))


class EventHandler(pyinotify.ProcessEvent):
    def __init__(self, keys):
        self._keys = keys

    def process_IN_CREATE(self, event):
        filepath = event.pathname
        
        # This will be the full path
        if filepath.endswith('.txt'):
           passwd = self._keys.pick_random_pass()
           process_dir.delay(passwd[0], passwd[1], filepath);

def main():
    _KEYS=KeyInfo()
    _KEYS.load_keys(os.environ['HOME'] + '/dms/conf/passwd.txt')

    wm = pyinotify.WatchManager()

    mask = pyinotify.IN_CREATE
    handler = EventHandler(_KEYS)
    notifier = pyinotify.Notifier(wm, handler)
    wdd = wm.add_watch('/dmsdocs/datastore', mask, rec=True)

    notifier.loop()

if __name__ == "__main__":
    main()

