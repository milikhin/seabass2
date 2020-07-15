"""Unit tests for fs_utils"""

import sys
from tempfile import gettempdir, TemporaryFile
from time import sleep
from os.path import join
from unittest.mock import patch
from fs_utils import list_files, get_editor_config, watch_changes, rename, rm

from .mocks import pyotherside
sys.modules['pyotherside'] = pyotherside

HOME = '/home/user'
DIR_NAME = 'dir'
DIR_PATH = join(HOME, DIR_NAME)
NESTED_FILE_NAME = 'foo'
NESTED_FILE_PATH = join(DIR_PATH, NESTED_FILE_NAME)

def _create_tmp_file():
    tmp_file = TemporaryFile()
    # modify the file to generate notification
    tmp_file.write(b"foo")
    tmp_file.close()

def _generate_notification():
    """
    Registers notification for tmp dir and create a file there.
    Should generate a notification
    """
    notification_thread = watch_changes([gettempdir()])
    sleep(0.25)
    _create_tmp_file()
    # wait for notifications thread to end
    notification_thread.join()

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

    result = list_files([HOME])['result']
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

    result = list_files([HOME, DIR_PATH])['result']

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

    result = list_files([HOME, DIR_PATH])['result']

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

@patch('pyotherside.send')
def test_notification_sent(send): # pylint: disable=invalid-name
    """#watch_changes should execute callback on file changes"""
    _generate_notification()
    send.assert_called_with('fs_event')

@patch('pyotherside.send')
def test_notification_only_sent_once(send): # pylint: disable=invalid-name
    """#watch_changes should not execute callback subsequent file changes"""
    _generate_notification()
    # check that modifying the file again once a notification has been triggered
    # doesn't generate a new notification
    send.reset_mock()
    _create_tmp_file()
    send.assert_not_called()

def test_rename_file(fs): # pylint: disable=invalid-name
    """#rename should rename files"""
    _setup_dir_with_file(fs)
    rename(NESTED_FILE_PATH, NESTED_FILE_PATH + '_renamed')
    assert fs.exists(NESTED_FILE_PATH + '_renamed')

def test_rename_dir(fs): # pylint: disable=invalid-name
    """#rename should rename directories"""
    _setup_dir_with_file(fs)
    rename(DIR_PATH, DIR_PATH + '_renamed')
    assert fs.exists(DIR_PATH + '_renamed')

def test_remove(fs): # pylint: disable=invalid-name
    """#remove should remove files"""
    _setup_dir_with_file(fs)
    rm(NESTED_FILE_PATH)
    assert not fs.exists(NESTED_FILE_PATH)
