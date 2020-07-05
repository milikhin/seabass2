"""FS utils for QML frontend"""

from os import listdir
from os.path import commonpath, dirname, exists, join, isdir, isfile, relpath
from functools import cmp_to_key
import pyotherside # pylint: disable=import-error
from helpers import exec_fn
from .watcher import Watcher

default_watcher = Watcher(callback=lambda: pyotherside.send('fs_event'))

def list_files(directories):
    """Returns listing of directory content using {error, result} format"""
    return exec_fn(lambda: _list_dir(directories))

def watch_changes(directories):
    """Watch for changes in given directories"""
    default_watcher.watch(directories)
    return default_watcher.get_notification_thread()

def _extract_file_info(directory, root_path, name):
    """Returns file description required for QML FileList component.

    Keyword arguments:
    directory -- file directory
    root_path -- current root directory (to estimate nested level)
    name -- file name
    """
    file_path = join(directory, name)
    rel_path = relpath(file_path, root_path)
    return {
        "name": name,
        "path": file_path,
        "dir_name": dirname(file_path),
        "is_file": isfile(file_path),
        "is_dir": isdir(file_path),
        "level": len(rel_path.split('/')) - 1
    }

def _extreact_qml_file_info(file):
    """Returns file object in QML-ready format"""
    return {
        "name": file["name"],
        "path": file["path"],
        "isFile": file["is_file"],
        "isDir": file["is_dir"],
        "level": file["level"]
    }

def _filename_comparator(a_str, b_str):
    """Compares file name (case insensitive)"""
    if a_str.lower() < b_str.lower():
        return -1
    if a_str.lower() > b_str.lower():
        return 1
    return 0

def _same_dir_file_comparator(a_file, b_file):
    """
    Cmp function for files within the same dir.
    Sorts directories first.
    """
    if a_file["is_dir"] and not b_file["is_dir"]:
        return -1
    if not a_file["is_dir"] and b_file["is_dir"]:
        return 1
    return _filename_comparator(a_file["name"], b_file["name"])

def _diff_dir_file_comparator(a_file, b_file):
    """
    Cmp function for files within different dirs.
    Entry's children are sorted before the next sibling.
    """
    a_dir_path = a_file["path"] if a_file["is_dir"] else a_file["dir_name"]
    b_dir_path = b_file["path"] if b_file["is_dir"] else b_file["dir_name"]
    common_path = commonpath([a_dir_path, b_dir_path])
    a_rel_path = relpath(a_dir_path, common_path)
    b_rel_path = relpath(b_dir_path, common_path)

    if a_rel_path == '.':
        return (-1 if not a_file["is_file"]
                and b_dir_path.startswith(a_file["path"])
                else 1)
    if b_rel_path == '.':
        return (1 if not b_file["is_file"]
                and a_dir_path.startswith(b_file["path"])
                else -1)

    return _filename_comparator(a_rel_path, b_rel_path)

def _file_comparator(a_file, b_file):
    """
    Comparator for sorting files list.
    Sorting order ensures that printing the list gives us in a tree-like representation:
    - dir1
    - dir1/nested_dir1
    - dir1/nested_dir1/very_nested_dir1
    - dir1/nested_file1
    - dir2
    - file1
    - ...

    Rules:
    - directories have priority over files at the same level
    - nested directories and files must follow parent directory
      (before any parent's siblings)
    """
    if a_file["dir_name"] == b_file["dir_name"]:
        return _same_dir_file_comparator(a_file, b_file)

    return _diff_dir_file_comparator(a_file, b_file)

def _list_dir(directories):
    """
    Returns listing of directory content

    Keyword arguments:
    directories -- directories to list files
    """
    request_dirs = list(filter(exists, directories))
    root_path = commonpath(request_dirs)
    dir_content = [_extract_file_info(directory, root_path, file_name)
                   for directory in request_dirs
                   for file_name in listdir(directory)]
    tree_entries = [file_or_dir for file_or_dir in dir_content
                    if file_or_dir["is_dir"] or file_or_dir["is_file"]]
    sorted_files = sorted(tree_entries, key=cmp_to_key(_file_comparator))
    return [_extreact_qml_file_info(file) for file in sorted_files]
