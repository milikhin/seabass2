"""Ubuntu content hub helpers"""
from os import listdir
from helpers import exec_fn

LOG_PATH = "/home/phablet/.cache/upstart/"
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
    source_log_file = None
    for log_entry in listdir(LOG_PATH):
        if app_name + ".log" in log_entry and not ".gz" in log_entry:
            source_log_file = log_entry

    if not source_log_file:
        raise Exception("Source log file is not found for {}".format(app_name))
    lines = open(LOG_PATH + source_log_file, "r").readlines()

    for line in reversed(lines):
        line = line.rstrip()
        if MAGIC_GUESS_LINE in line and file_name in line:
            return line.split("file://")[-1]

    raise Exception("Unable to guess original file path for {}:{}".format(app_name, file_name))
