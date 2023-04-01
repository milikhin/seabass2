"""The module provides build environment inside a Libertine container"""

import subprocess
import re
from os import remove
from os.path import dirname, join, dirname, realpath
from shutil import copytree
from textwrap import dedent
from psutil import Process

from libertine.Libertine import LibertineContainer, ContainersConfig # pylint: disable=import-error

from helpers import exec_cmd
from .config import PACKAGES
from .helpers import get_create_cmd,\
    get_create_project_cmd, get_run_clickable_cmd, get_hide_apps_cmd,\
    get_destroy_cmd, get_install_cmd, get_launch_cmd, get_clickable_ppa_cmd,\
    get_node_ppa_cmd, get_install_lsp_proxy_cmd, get_run_lsp_proxy_cmd,\
    get_install_typescript_ls_cmd, get_install_python_ls_cmd

# This function is available in Python but doesn't provide any status updates:
#   `self._container.start_application(cmd, environ)`

class BuildEnv:
    """
    Build environment inside a chroot Libertine container
    """
    def __init__(self, container_id, print_renderer=print):
        self._data_dir = '/home/phablet/.local/share/seabass2.mikhael/'
        self._src_scripts_dir = join(dirname(realpath(__file__)), 'shell_scripts')
        self._scripts_dir = join(self._data_dir, 'shell_scripts')
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

    def build(self, config_file, install=False):
        """
        Executes clickable --config=<config_file> from a <config_file> directory

        Keyword arguments:
        config_file -- path to clickable.json
        install -- true to install/launch buit app
        """
        cmd = get_run_clickable_cmd(config_file)
        cwd = dirname(config_file)
        last_line = self._shell_exec(cmd, cwd)
        if install is False:
            return

        click_names = re.findall(r'^Successfully built package in \'\.\/(.*)\'', last_line)
        if len(click_names) == 1:
            self._print('Installing {} package.'.format(click_names[0]))
            install_cmd = get_install_cmd(click_names[0])
            self._shell_exec(install_cmd, cwd)
            app_namings = re.findall(r'^(.*?)\.(.*?)_', click_names[0])
            if len(app_namings) == 1:
                self._print('Launching app.')
                launch_app_cmd = get_launch_cmd(app_namings[0][0], app_namings[0][1])
                self._shell_exec(launch_app_cmd, cwd, True)
            else:
                self._print('Unable to launch app (can\'t find app name)')
        else:
            self._print('Unable to install app (can\'t locate package file)')

    def create(self, dir_name, options):
        """
        Executes clickable --config=<config_file> from a <config_file> directory

        Keyword arguments:
        options -- path to clickable.json
        """
        cmd = get_create_project_cmd(options)
        self._shell_exec(cmd, dir_name)

    def start_ls(self):
        cmd = get_run_lsp_proxy_cmd(self._data_dir)
        self._shell_exec(cmd)

    def test_container_exists(self):
        """Returns True if Seabass Libertine container exists, False otherwise"""
        self._libertine_config.refresh_database()
        return self._libertine_config.container_exists(self._container_id)

    def update_container(self):
        """Installs missing packages / upgrades installed packages within the container"""
        self._copy_scripts()
        self._install_packages()

    def _create_container(self):
        cmd = get_create_cmd()
        self._shell_exec(cmd)
        return self._get_container()

    def _destroy_container(self):
        cmd = get_destroy_cmd()
        self._shell_exec(cmd)

    def _shell_exec(self, cmd, cwd='/home/phablet', nowait=False):
        res = ''
        for stdout_line in exec_cmd(cmd, cwd, nowait):
            self._print(stdout_line, eol='')
            res = stdout_line
        return res

    def _get_container(self):
        self._libertine_config.refresh_database()
        return LibertineContainer(self._container_id, self._libertine_config)

    def _install_packages(self):
        self._container.update_libertine_container()
        has_error = False
        for package in PACKAGES:
            self._print("Installing {}...".format(package))
            install_succeeded = self._container.install_package(package,
                                                                update_cache=False, no_dialog=True)
            if not install_succeeded:
                has_error = True

        if has_error:
            self._print('[WARNING]: apt reported errors while installing required packages. '
            'This is just a notice. It might be expected or non-critical.')

    def _install_lsp_proxy(self):
        cmd = get_install_lsp_proxy_cmd()
        self._shell_exec(cmd)

    def _install_typescript_ls(self):
        cmd = get_install_typescript_ls_cmd()
        self._shell_exec(cmd)

    def _install_python_ls(self):
        cmd = get_install_python_ls_cmd()
        self._shell_exec(cmd)

    def _hide_apps_from_grid(self):
        cmd = get_hide_apps_cmd()
        self._shell_exec(cmd)

    def _add_ppas(self):
        node_ppa_cmd = get_node_ppa_cmd()
        clickable_ppa_cmd = get_clickable_ppa_cmd(self._scripts_dir)
        self._shell_exec(node_ppa_cmd)
        self._shell_exec(clickable_ppa_cmd)

    def _copy_scripts(self):
        copytree(self._src_scripts_dir, self._scripts_dir, dirs_exist_ok=True)
        self._libertine_config.add_new_bind_mount(container_id=self._container_id,
                                                  mount_path=self._data_dir)

    def _print(self, message, margin_top=False, eol='\n'):
        delimeter_top = '\n\n' if margin_top else ''
        self._print_renderer('{}{}{}'.format(delimeter_top, message, eol))

    def _setup_container(self):
        try:
            self._print('Initializing a new Libertine container to run Clickable.')
            self._print('Step 1/4. Creating a container.')
            self._container = self._create_container()

            self._print('Step 2/4. Installing required packages.', margin_top=True)
            self._copy_scripts()
            self._add_ppas()
            self._install_packages()

            self._print('Step 3/4. Initializing language server protocol support.', margin_top=True)
            self._install_lsp_proxy()
            self._install_typescript_ls()
            self._install_python_ls()

            self._print("Step 4/4. Hiding GUI applications from the App Grid.", margin_top=True)
            self._hide_apps_from_grid()

            self._print("DONE: Build container has been successfully created", margin_top=True)
        except subprocess.CalledProcessError as err:
            self._print('ERROR: Creating a container failed', margin_top=True)
            self._print(err)
            raise Exception('Creating a container failed') from err
        except Exception as err:
            self._print('ERROR: Setting up a container failed', margin_top=True)
            self._print(err)
            if self.test_container_exists():
                self._print('Deleting created container...', margin_top=True)
                self._destroy_container()
                self._print('Container has been deleted')
            raise Exception('Setting up a container failed') from err
