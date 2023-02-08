from shutil import which

def test_exec(cmd):
    if which(cmd) is None:
        return False
    return True
