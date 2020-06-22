"""Unit tests for build_utils"""

import sys
import subprocess
from os.path import dirname
from unittest.mock import patch

from .mocks import Libertine, pyotherside # pylint: disable=wrong-import-order
sys.modules['libertine.Libertine'] = Libertine
sys.modules['pyotherside'] = pyotherside
from build_utils import scripts, helpers # pylint: disable=wrong-import-position

@patch('build_utils.build_environment.shell_exec')
def test_create_new_container(shell_exec):
    """Should create container if not exists"""

    config_file = 'foo/bar'
    res = scripts.build(config_file)

    cmd = helpers.get_create_cmd()
    shell_exec.assert_any_call(cmd, None)
    assert not 'error' in res

@patch('build_utils.build_environment.shell_exec')
def test_create_error(shell_exec):
    """Should raise and print errors"""

    cmd = 'foo/bar'
    shell_exec.side_effect = subprocess.CalledProcessError(cmd=cmd, returncode=1)
    res = scripts.build(cmd)
    assert 'error' in res
    assert not 'result' in res

@patch('build_utils.build_environment.shell_exec')
def test_install_error_cleanup(shell_exec): # pylint: disable=unused-argument
    """Should destroy container if installation failed"""

    cmd = 'foo/bar'
    with patch.object(Libertine.LibertineContainer, 'install_package') as install_mock:
        install_mock.return_value = False # any error
        with patch.object(Libertine.ContainersConfig, 'container_exists') as container_exists:
            container_exists.side_effect = [False, True]
            with patch.object(Libertine.LibertineContainer,
                              'destroy_libertine_container') as destroy_mock:
                scripts.build(cmd)
                destroy_mock.assert_called()

@patch('build_utils.build_environment.shell_exec')
def test_install_error(shell_exec): # pylint: disable=unused-argument
    """Should raise and print errors"""

    with patch.object(Libertine.LibertineContainer, 'install_package') as install_mock:
        install_mock.return_value = False # any error
        res = scripts.build('foo/bar')
        assert 'error' in res
        assert not 'result' in res


@patch('build_utils.build_environment.shell_exec')
def test_use_existing_container(shell_exec):
    """Should use existing container possible"""

    with patch.object(Libertine.ContainersConfig, 'container_exists') as container_exists:
        container_exists.return_value = True
        config_file = 'foo/bar'
        scripts.build(config_file)

        # check that shell_exec has only been called once: to exec clickable
        assert shell_exec.call_count == 1
        cmd = helpers.get_run_clickable_cmd(config_file)
        shell_exec.assert_called_with(cmd, dirname(config_file))

@patch('build_utils.build_environment.shell_exec')
def test_build_command(shell_exec):
    """Should execute clickable build"""

    config_file = 'foo/bar'
    scripts.build(config_file)

    cmd = helpers.get_run_clickable_cmd(config_file)
    shell_exec.assert_called_with(cmd, dirname(config_file))

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
