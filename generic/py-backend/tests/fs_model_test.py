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
