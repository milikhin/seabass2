"""Delete files/directories"""
from os import remove
from os.path import isfile
from shutil import rmtree
from helpers import exec_fn

def rm(path): # pylint: disable=invalid-name
    """Removes file or dir at the given path, returns {error} if something goes wrong"""
    return exec_fn(lambda: _rm(path))

def _rm(path):
    """Removes file or dir at the given path"""
    if isfile(path):
        return remove(path)
    return rmtree(path)
