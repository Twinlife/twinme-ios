#!/usr/bin/env python

import shutil, os
import fileinput
from subprocess import call

paths = ['Pods/Headers', 'Podfile.lock', 'Twinme.xcworkspace']

for path in paths:
    try:
        if os.path.isfile(path):
            os.remove(path)
            print("%s deleted..." % (path))
        elif os.path.isdir(path):
            shutil.rmtree(path)
            print("%s deleted..." % (path))
    except:
        pass

call(['pod', 'install'])
