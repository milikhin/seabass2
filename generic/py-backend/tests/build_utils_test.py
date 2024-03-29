"""Unit tests for build_utils"""

import sys
import subprocess
from os.path import dirname
from unittest.mock import patch

from .mocks import Libertine, pyotherside # pylint: disable=wrong-import-order
sys.modules['libertine.Libertine'] = Libertine
sys.modules['pyotherside'] = pyotherside
from build_utils import scripts, helpers # pylint: disable=wrong-import-position

DEFAULT_CWD = '/home/phablet'

@patch('build_utils.build_environment.exec_cmd')
def test_create_new_container(shell_exec):
    """Should create container if not exists"""

    config_file = 'foo/bar'
    scripts.build(config_file)

    cmd = helpers.get_create_cmd()
    shell_exec.assert_any_call(cmd, DEFAULT_CWD, False)

@patch('build_utils.build_environment.exec_cmd')
def test_create_error(shell_exec):
    """Should raise and print errors"""

    cmd = 'foo/bar'
    shell_exec.side_effect = subprocess.CalledProcessError(cmd=cmd, returncode=1)
    res = scripts.build(cmd)
    assert 'error' in res
    assert not 'result' in res

@patch('build_utils.build_environment.exec_cmd')
def test_install_error_cleanup(shell_exec): # pylint: disable=unused-argument
    """Should destroy container if installation failed"""

    cmd = 'foo/bar'
    destroy_cmd = helpers.get_destroy_cmd()
    with patch.object(Libertine.LibertineContainer, 'install_package') as install_mock:
        install_mock.return_value = False # any error
        with patch.object(Libertine.ContainersConfig, 'container_exists') as container_exists:
            container_exists.side_effect = [False, True]
            scripts.build(cmd)
            shell_exec.assert_called_with(destroy_cmd, DEFAULT_CWD, False)

@patch('build_utils.build_environment.exec_cmd')
def test_install_error(shell_exec): # pylint: disable=unused-argument
    """Should raise and print errors"""

    with patch.object(Libertine.LibertineContainer, 'install_package') as install_mock:
        install_mock.return_value = False # any error
        res = scripts.build('foo/bar')
        assert 'error' in res
        assert not 'result' in res


@patch('build_utils.build_environment.exec_cmd')
def test_use_existing_container(shell_exec):
    """Should use existing container possible"""

    with patch.object(Libertine.ContainersConfig, 'container_exists') as container_exists:
        container_exists.return_value = True
        config_file = 'foo/bar'
        scripts.build(config_file)

        # check that shell_exec has only been called once: to exec clickable
        assert shell_exec.call_count == 1
        cmd = helpers.get_run_clickable_cmd(config_file)
        shell_exec.assert_called_with(cmd, dirname(config_file), False)

@patch('build_utils.build_environment.exec_cmd')
def test_build_command(shell_exec):
    """Should execute clickable build"""

    with patch.object(Libertine.ContainersConfig, 'container_exists') as container_exists:
        container_exists.return_value = True
        config_file = 'foo/bar'
        scripts.build(config_file)

        cmd = helpers.get_run_clickable_cmd(config_file)
        shell_exec.assert_called_with(cmd, dirname(config_file), False)

@patch('build_utils.build_environment.exec_cmd')
def test_create_command(shell_exec):
    """Should execute clickable create"""

    with patch.object(Libertine.ContainersConfig, 'container_exists') as container_exists:
        container_exists.return_value = True
        dir_name = 'foo'
        options = {'name': 'bar', 'description': 'baz'}
        scripts.create(dir_name, options)

        cmd = helpers.get_create_project_cmd(options)
        shell_exec.assert_called_with(cmd, dir_name, False)

def test_test_container_exists_false():
    """Should return False if container not exists"""

    res = scripts.test_container_exists()
    assert res == {'result': False}

def test_test_container_exists_true():
    """Should return True if container exists"""

    with patch.object(Libertine.ContainersConfig, 'container_exists') as container_exists:
        container_exists.return_value = True
        res = scripts.test_container_exists()
        assert res == {'result': True}
