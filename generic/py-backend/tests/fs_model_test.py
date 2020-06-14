"""Unit tests for fs_model.py"""

from os.path import join
from fs_utils import list_dir

def test_same_dir_files(fs): # pylint: disable=invalid-name
    """Should sort files in the same dir alphabetically"""
    home = '/home/user'
    file0 = join(home, 'foo')
    file1 = join(home, 'bar')
    fs.create_file(file0)
    fs.create_file(file1)

    result = list_dir(home)
    assert len(result) == 2
    assert result[0] == {
        "name": "bar",
        "path": file1,
        "isDir": False,
        "isFile": True,
        "level": 0
    }
    assert result[1] == {
        "name": "foo",
        "path": file0,
        "isDir": False,
        "isFile": True,
        "level": 0
    }

def test_diff_dir_files(fs): # pylint: disable=invalid-name
    """Should sort nested children before next sibling"""
    home = '/home/user'
    file0 = join(home, 'abc')
    file1 = join(home, 'abc/foo')
    file2 = join(home, 'bar')
    fs.create_dir(file0)
    fs.create_file(file1)
    fs.create_file(file2)

    result = list_dir(home, [file0])
    assert len(result) == 3
    assert result[0] == {
        "name": "abc",
        "path": file0,
        "isDir": True,
        "isFile": False,
        "level": 0
    }
    assert result[1] == {
        "name": "foo",
        "path": file1,
        "isDir": False,
        "isFile": True,
        "level": 1
    }
    assert result[2] == {
        "name": "bar",
        "path": file2,
        "isDir": False,
        "isFile": True,
        "level": 0
    }
