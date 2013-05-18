#!/usr/bin/python

import os, json, requests

FORGE = u'https://forge.puppetlabs.com'
ANVIL = u'/var/tmp/blacksmith'

class PuppetModule(dict):
  def __init__(self, **kwargs):
    self.__keys = kwargs.keys()
    for key, value in kwargs.iteritems():
      setattr(self, key, value)
      self[key] = value

  def releasefile(self):
    return u'{full_name}/{version}.tar.gz'.format(**self)


class PuppetModules(list):
  def get(self, key, value):
    found = []
    for module in self:
      if module.key == value:
        found.append(module)


def verify_directory(directory):
  if not os.path.exists(directory):
    os.mkdir(directory)
  elif not os.path.isdir(directory):
    raise Exception, 'Path is not a directory'
  elif not os.access(directory, os.W_OK):
    raise Exception, 'Invalid permissions on {0}'.format(directory)
  
def download_modules_metadata(base_url):
  return json.loads(requests.get( os.path.join(base_url, u'modules.json')).content)

def download_module(module, forge=FORGE, anvil=ANVIL):
  releasefile = module.releasefile()
  source_url = os.path.join(forge, releasefile)
  verify_directory(os.path.join(anvil, module.author))
  destination = os.path.join(anvil, releasefile)
  verify_directory(os.path.split(destination)[0])
  open(destination,'w').write(requests.get(os.path.join(forge, releasefile)).content)