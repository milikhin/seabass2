from os import listdir
from os.path import isdir, isfile, join

def extract_file_info(directory, name):
    file_path = join(directory, name)
    return {
        "name": name,
        "path": file_path,
        "isFile": isfile(file_path),
        "isDir": isdir(file_path)
    }

def list_dir(path, expanded=[]):
    all_dirs = [*expanded, path]
    # print([extract_file_info(directory, file_name) for directory in all_dirs for file_name in listdir(directory)])
    return [extract_file_info(directory, file_name) for directory in all_dirs for file_name in listdir(directory)]
