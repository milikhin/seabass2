"""Python scripts executable from the QML app"""

import pyotherside # pylint: disable=import-error

from helpers import exec_fn
from .build_environment import BuildEnv
from .config import CONTAINER_ID
from .helpers import patch_env

def build(config_file, install=False):
    """
    Runs build for the given clickable.json file

    Keyword arguments:
    config_file -- path to clickable.json
    install -- true to install/launch buit app
    """
    return exec_fn(lambda: _build(config_file, install))

def create(dir_name, options):
    """
    Creates a new project

    Keyword arguments:
    options -- options for `clickable create --non-interactive ...`
    """
    return exec_fn(lambda: _create(dir_name, options))

def ensure_container():
    """
    Creates a Libertine container to execute clickable if not exists
    """
    return exec_fn(_init_container)

def update_container():
    """
    Upgrades built tools within a Libertine container
    """
    return exec_fn(_update_container)

def test_container_exists():
    """Returns True if Libertine container exists, False otherwise"""
    return exec_fn(_test_container_exists)

def _init_container():
    patch_env()
    build_env = BuildEnv(container_id=CONTAINER_ID,
                         print_renderer=lambda txt: pyotherside.send('stdout', txt))
    build_env.init_container()
    return build_env

def _build(config_file, install):
    build_env = _init_container()
    return build_env.build(config_file, install)

def _create(dir_name, options):
    build_env = _init_container()
    return build_env.create(dir_name, options)

def _test_container_exists():
    build_env = BuildEnv(container_id=CONTAINER_ID, print_renderer=pyotherside.send)
    return build_env.test_container_exists()

def _update_container():
    build_env = _init_container()
    return build_env.update_container()
