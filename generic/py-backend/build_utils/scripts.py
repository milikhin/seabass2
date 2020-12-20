"""Python scripts executable from the QML app"""

import pyotherside # pylint: disable=import-error

from helpers import exec_fn
from .build_environment import BuildEnv
from .config import CONTAINER_ID
from .helpers import patch_env

def build(config_file):
    """
    Runs build for the given clickable.json file

    Keyword arguments:
    config_file -- path to clickable.json
    """
    return exec_fn(lambda: _build(config_file))

def ensure_container():
    """
    Creates a Libertine container to execute clickable if not exists
    """
    return exec_fn(_init_container)

def test_container_exists():
    """Returns Trues if Libertine container exists, False otherwise"""
    return exec_fn(_test_container_exists)

def _init_container():
    patch_env()
    build_env = BuildEnv(container_id=CONTAINER_ID,
                         print_renderer=lambda txt: pyotherside.send('stdout', txt))
    build_env.init_container()
    return build_env

def _build(config_file):
    build_env = _init_container()
    return build_env.build(config_file)

def _test_container_exists():
    build_env = BuildEnv(container_id=CONTAINER_ID, print_renderer=pyotherside.send)
    return build_env.test_container_exists()
