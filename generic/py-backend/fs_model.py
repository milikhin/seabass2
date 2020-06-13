"""FS utils for QML frontend"""

from os import listdir
from os.path import commonpath, dirname, join, isdir, isfile, relpath
from functools import cmp_to_key

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
    if a_file["id_dir"] and not b_file["id_dir"]:
        return -1
    if not a_file["id_dir"] and b_file["id_dir"]:
        return 1
    return _filename_comparator(a_file["name"], b_file["name"])

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
        _same_dir_file_comparator(a_file, b_file)

    a_dir_path = a_file["path"] if a_file["id_dir"] else a_file["dir_name"]
    b_dir_path = b_file["path"] if b_file["id_dir"] else b_file["dir_name"]
    common_path = commonpath([a_dir_path, b_dir_path])

    a_rel_path = relpath(a_dir_path, common_path)
    b_rel_path = relpath(b_dir_path, common_path)
    if a_rel_path == '.':
        if a_file["isFile"]:
            return 1
        return -1 if b_dir_path.startswith(a_file["path"]) else 1
    if b_rel_path == '.':
        if b_file["isFile"]:
            return -1
        return 1 if a_dir_path.startswith(b_file["path"]) else -1
    return _filename_comparator(a_rel_path, b_rel_path)

def list_dir(root_directory, expanded_children=None):
    """
    Returns listing of directory content

    Keyword arguments:
    root_directory -- root directory
    expanded_children -- list of expanded nested directories
    """
    if expanded_children is None:
        expanded_children = []

    request_dirs = [root_directory, *expanded_children]
    root_path = commonpath(request_dirs)
    dir_content = [_extract_file_info(directory, root_path, file_name)
                   for directory in request_dirs
                   for file_name in listdir(directory)]
    tree_entries = [file_or_dir for file_or_dir in dir_content
                    if file_or_dir["is_dir"] or file_or_dir["is_file"]]
    sorted_files = sorted(tree_entries, key=cmp_to_key(_file_comparator))
    return [_extreact_qml_file_info(file) for file in sorted_files]
