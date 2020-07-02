"""Unit tests for fs_utils"""

from os.path import join
from fs_utils import list_dir, get_editor_config

HOME = '/home/user'
DIR_NAME = 'dir'
DIR_PATH = join(HOME, DIR_NAME)
NESTED_FILE_NAME = 'foo'
NESTED_FILE_PATH = join(DIR_PATH, NESTED_FILE_NAME)

def _setup_dir_with_file(fs): # pylint: disable=invalid-name
    fs.create_dir(DIR_PATH)
    fs.create_file(NESTED_FILE_PATH)

def _assert_dir_goes_first(list_res, ):
    assert list_res[0] == {
        "name": DIR_NAME,
        "path": DIR_PATH,
        "isDir": True,
        "isFile": False,
        "level": 0
    }
    # directory's child follows directory
    assert list_res[1] == {
        "name": NESTED_FILE_NAME,
        "path": NESTED_FILE_PATH,
        "isDir": False,
        "isFile": True,
        "level": 1
    }

def test_same_dir_files(fs): # pylint: disable=invalid-name
    """Should sort files in the same dir alphabetically"""

    file0 = join(HOME, 'foo')
    file1 = join(HOME, 'bar')
    file2 = join(HOME, 'baz')
    fs.create_file(file0)
    fs.create_file(file1)
    fs.create_file(file2)

    result = list_dir(HOME)['result']
    assert len(result) == 3
    assert result[0] == {
        "name": "bar",
        "path": file1,
        "isDir": False,
        "isFile": True,
        "level": 0
    }
    assert result[1] == {
        "name": "baz",
        "path": file2,
        "isDir": False,
        "isFile": True,
        "level": 0
    }
    assert result[2] == {
        "name": "foo",
        "path": file0,
        "isDir": False,
        "isFile": True,
        "level": 0
    }

def test_diff_dir_file_lt(fs): # pylint: disable=invalid-name
    """
    Should sort nested children before next sibling
    (sibling file name is lower than dir name)
    """

    file_path_lt_dir = join(HOME, 'a')
    fs.create_file(file_path_lt_dir)
    _setup_dir_with_file(fs)

    result = list_dir(HOME, [DIR_PATH])['result']

    # check that all files are listed
    assert len(result) == 3
    # check that directory is listed first
    _assert_dir_goes_first(result)

    # file is listed after the directory
    assert result[2] == {
        "name": "a",
        "path": file_path_lt_dir,
        "isDir": False,
        "isFile": True,
        "level": 0
    }

def test_diff_dir_file_gt(fs): # pylint: disable=invalid-name
    """
    Should sort nested children before next sibling
    (sibling file name is greater than dir name)
    """

    _setup_dir_with_file(fs)
    file_path_gt_dir = join(HOME, 'z')
    fs.create_file(file_path_gt_dir)

    result = list_dir(HOME, [DIR_PATH])['result']

    # check that all files are listed
    assert len(result) == 3
    # check that directory is listed first
    _assert_dir_goes_first(result)

    # file is listed after the directory
    assert result[2] == {
        "name": "z",
        "path": file_path_gt_dir,
        "isDir": False,
        "isFile": True,
        "level": 0
    }

def test_editor_config_exists(fs): # pylint: disable=invalid-name
    """#get_editor_config should return indentation preferences"""
    _setup_dir_with_file(fs)
    fs.create_file(join(DIR_PATH, '.editorconfig'), contents="""
                   [**]
                   indent_style = space
                   indent_size = 9
                   """)
    config = get_editor_config(NESTED_FILE_PATH)['result']
    assert config == {
        "indent_style": "space",
        "indent_size": "9",
        "tab_width": "9"
    }

def test_editor_config_not_exists(fs): # pylint: disable=invalid-name
    """#get_editor_config should return empty object if .editorconfig doesn't exist"""
    _setup_dir_with_file(fs)
    config = get_editor_config(NESTED_FILE_PATH)['result']
    assert config == {}
