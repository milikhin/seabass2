from os import listdir
from os.path import isfile, join

def extract_file_info(directory, name):
    file_path = join(directory, name)
    return {
        "name": name,
        "path": file_path,
        "isFile": isfile(file_path)
    }

def list_dir(path):
    print(path)
    return [extract_file_info(path, file_name) for file_name in listdir(path)]
