"""
Contains which util
"""
from shutil import which

def test_exec(cmd):
    """Checks if given executable exists"""
    if which(cmd) is None:
        return False
    return True
