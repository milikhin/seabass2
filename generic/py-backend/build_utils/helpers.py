"""Helpers for build utils"""

import subprocess
import shlex
from os import environ
from os.path import dirname
from .config import CONTAINER_ID

def shell_exec(command_string):
    """
    Executes given subprocess, returns iterable list of stdout lines

    Keyword arguments:
    command_string -- cmd string to execute
    """
    cmd_args = shlex.split(command_string)
    process = subprocess.Popen(cmd_args,
                               stdout=subprocess.PIPE,
                               universal_newlines=True)

    for stdout_line in iter(process.stdout.readline, ''):
        yield stdout_line
    process.stdout.close()
    return_code = process.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, command_string)

def get_create_cmd():
    """Returns cmd string to create Seabass Libertine container"""
    return 'libertine-container-manager create -i {} -t chroot'\
        .format(CONTAINER_ID)

def get_install_clickable_cmd():
    """Returns cmd string to install clickable into a Seabass Libertine container"""
    return 'libertine-launch -i {} \
            pip3 install --user git+https://gitlab.com/clickable/clickable.git@dev'\
        .format(CONTAINER_ID)

def get_run_clickable_cmd(config_file):
    """Returns cmd string to run clickable from a Seabass Libertine container"""
    return 'libertine-launch -i {} \
            bash -c "(cd {}; clickable --container-mode --config={}")'\
        .format(CONTAINER_ID, dirname(config_file), config_file)

def patch_env():
    """
    Sets TMPDIR var to existing /tmp directory.
    Prevents issues with various Libertine commands
    """
    environ['TMPDIR'] = '/tmp'
