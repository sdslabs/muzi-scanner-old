__author__ = 'admin'

import os
import sys

walk_dir = sys.argv[1]

print('walk_dir = ' + walk_dir)

# If your current working directory may change during script execution, it's recommended to
# immediately convert program arguments to an absolute path. Then the variable root below will
# be an absolute path as well. Example:
# walk_dir = os.path.abspath(walk_dir)
print('walk_dir (absolute) = ' + os.path.abspath(walk_dir))


for root, subdirs, files in os.walk(walk_dir):
    if root==os.path.join(walk_dir,'English'):
        print "artists %s"%files
