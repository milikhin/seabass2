"""The module provides build environment inside a Libertine container"""

import subprocess
from os.path import dirname

from libertine.Libertine import LibertineContainer, ContainersConfig # pylint: disable=import-error

from .config import CONTAINER_ID, PACKAGES
from .helpers import shell_exec, get_create_cmd, get_install_clickable_cmd,\
    get_run_clickable_cmd, get_delete_desktop_files_cmd, get_destroy_cmd

class BuildEnv:
    """
    Build environment inside a chroot Libertine container
    """
    def __init__(self, container_id, print_renderer=print):
        self._container_id = container_id
        self._print_renderer = print_renderer
        self._libertine_config = ContainersConfig()
        self._container = None

    def init_container(self):
        """Returns a Libertine container for the Seabass"""
        try:
            if self.test_container_exists():
                self._container = self._get_container()
            else:
                self._setup_container()
        except Exception as error:
            self._print(error)
            raise error

    def build(self, config_file):
        """
        Executes clickable --config=<config_file> from a <config_file> directory

        Keyword arguments:
        config_file -- path to clickable.json
        """
        cmd = get_run_clickable_cmd(config_file)
        cwd = dirname(config_file)
        return self._shell_exec(cmd, cwd)

    def test_container_exists(self):
        """Returns True if Seabass Libertine container exists, False otherwise"""
        self._libertine_config.refresh_database()
        return self._libertine_config.container_exists(self._container_id)

    def _create_container(self):
        cmd = get_create_cmd()
        self._shell_exec(cmd)
        return self._get_container()

    def _destroy_container(self):
        cmd = get_destroy_cmd()
        self._shell_exec(cmd)

    def _shell_exec(self, cmd, cwd=None):
        for stdout_line in shell_exec(cmd, cwd):
            self._print(stdout_line, eol='')

    def _get_container(self):
        self._libertine_config.refresh_database()
        return LibertineContainer(CONTAINER_ID, self._libertine_config)

    def _install_packages(self):
        self._container.update_libertine_container()
        for package in PACKAGES:
            self._print("Installing {}...".format(package))
            install_succeeded = self._container.install_package(package,
                                                                update_cache=False, no_dialog=True)
            if not install_succeeded:
                raise Exception("Installing {} failed".format(package))

    def _delete_desktop_files(self):
        cmd = get_delete_desktop_files_cmd()
        self._print("Deleting container applications from the App Grid...")
        self._shell_exec(cmd)

    def _install_clickable(self):
        cmd = get_install_clickable_cmd()
        # This function is available in Python but doesn't provide progress:
        #   `self._container.start_application(cmd, environ)`
        self._shell_exec(cmd)

    def _print(self, message, margin_top=False, eol='\n'):
        delimeter_top = '\n\n' if margin_top else ''
        self._print_renderer('{}{}{}'.format(delimeter_top, message, eol))

    def _setup_container(self):
        try:
            self._print('Initializing a new Libertine container to run Clickable.')
            self._print('Step 1/3. Creating a container.')
            self._container = self._create_container()

            self._print('Step 2/3. Installing required packages.', margin_top=True)
            self._install_packages()

            self._print('Step 3/3. Installing Clickable.', margin_top=True)
            self._install_clickable()
            self._delete_desktop_files()
        except subprocess.CalledProcessError as err:
            self._print('ERROR: Creating a container failed', margin_top=True)
            self._print(err)
            raise Exception('Creating a container failed')
        except Exception as err:
            self._print('ERROR: Setting up a container failed', margin_top=True)
            self._print(err)
            if self.test_container_exists():
                self._print('Deleting created container. Please wait...', margin_top=True)
                self._destroy_container()
                self._print('Container has been deleted')
            raise Exception('Setting up a container failed')
