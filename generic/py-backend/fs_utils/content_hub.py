"""Ubuntu content hub helpers"""
from helpers import exec_fn, exec_cmd

MAGIC_GUESS_LINE = "resolveContentType for file"

def guess_file_path(app_name, file_name):
    """Guesses file path based on Content source and file name"""
    return exec_fn(lambda: _guess(app_name, file_name))

def _guess(app_name, file_name):
    """
    HAK!
    We are going to parse filemanager logs to guess content hub's source file's name

    Thanks to https://gitlab.com/BlueKenny/uText/-/blob/master/qml/Main.py
    """
    cmd = "journalctl -r --user --no-pager -u \
          lomiri-app-launch--application-click--{}--".format(app_name)

    for line in exec_cmd(cmd):
        line = line.rstrip()
        if MAGIC_GUESS_LINE in line and file_name in line:
            return line.split("file://")[-1]

    raise Exception("Unable to guess original file path for {}:{}".format(app_name, file_name))
