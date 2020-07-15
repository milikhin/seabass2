"""Rename files/directories"""
from os import rename as os_rename
from helpers import exec_fn

def rename(path, new_path):
    """Rename file or dir, returns {error} if something goes wrong"""
    return exec_fn(lambda: os_rename(path, new_path))
