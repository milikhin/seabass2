"""Utils to read editorConfig profiles"""
from editorconfig import get_properties
from helpers import exec_fn

def get_editor_config(file_path):
    """
    Returns editorConfig profile for the file at given path

    Keyword arguments:
    file_path -- /path/to/file
    """
    return exec_fn(lambda: get_properties(file_path))
