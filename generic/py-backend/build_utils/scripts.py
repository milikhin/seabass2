"""Python scripts executable from the QML app"""
import pyotherside
from .build_environment import BuildEnv
from .config import CONTAINER_ID
from .helpers import patch_env

def printer(message):
    """Print message to 'stdoud'"""
    return pyotherside.send(message)

def build(config_file):
    """
    Runs build for the given clickable.json file

    Keyword arguments:
    config_file -- path to clickable.json
    """
    return _exec_command(lambda: _build(config_file))

def test_container_exists():
    """Returns Trues if Libertine container exists, False otherwise"""
    return _exec_command(_test_container_exists)

def _exec_command(func):
    try:
        return {'result': func()}
    except Exception as error:
        return {'error': str(error)}

def _build(config_file):
    patch_env()
    build_env = BuildEnv(container_id=CONTAINER_ID, print_renderer=pyotherside.send)
    build_env.init_container()
    return build_env.build(config_file)

def _test_container_exists():
    build_env = BuildEnv(container_id=CONTAINER_ID, print_renderer=pyotherside.send)
    return build_env.test_container_exists()
