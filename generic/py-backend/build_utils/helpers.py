"""Helpers for build utils"""

from os import environ
from .config import CONTAINER_ID, CONTAINER_NAME

def get_create_cmd():
    """Returns cmd string to create Seabass Libertine container"""
    return 'libertine-container-manager create -i {} -n "{}" -t chroot'\
        .format(CONTAINER_ID, CONTAINER_NAME)

def get_destroy_cmd():
    """Returns cmd string to destroy Seabass Libertine container"""
    return 'libertine-container-manager destroy -i {}'\
        .format(CONTAINER_ID)

def get_launch_cmd(app_name, developer_name):
    """Returns cmd string to launch application"""
    return 'bash -c "ubuntu-app-launch {0}.{1}_{0} &"'\
        .format(app_name, developer_name)

def get_container_cmd(command_string):
    """
    Returns cmd string wrapped into a libertine-launch call

    Keyword arguments:
    command_string -- cmd string to execute
    """
    return 'libertine-launch -i {} bash -i -c "{}"'.format(CONTAINER_ID, command_string)

def get_run_clickable_cmd(config_file):
    """Returns cmd string to run clickable from a Seabass Libertine container"""
    return get_container_cmd('clickable build --non-interactive --container-mode \
            --skip-review --config={}'.format(config_file))

def get_install_cmd(click_name):
    """Returns cmd string to run clickable from a Seabass Libertine container"""
    return 'bash -c "pkcon install-local --allow-untrusted $(find -name {})"'\
        .format(click_name)

def get_create_project_cmd(options):
    """Returns cmd string to run clickable from a Seabass Libertine container"""
    create_args = ''
    for key in options:
        if options[key] is True:
            create_args += ' --{}'.format(key)
        elif options[key]:
            create_args += ' --{} "{}"'.format(key, options[key])
    return get_container_cmd('clickable create --non-interactive --container-mode {}'\
        .format(create_args))

def get_node_ppa_cmd():
    """Returns cmd to add Node.js PPA"""
    return 'libertine-container-manager exec -i {} -c \
            "bash -c \'wget -qO- https://deb.nodesource.com/setup_18.x | bash\'"'\
            .format(CONTAINER_ID)

def get_clickable_ppa_cmd(scripts_dir):
    """Returns cmd to add Clickable PPA containing 'click' tools"""
    return 'libertine-container-manager exec -i {} -c \
            "bash {}/01-setup-ppas.sh"'\
            .format(CONTAINER_ID, scripts_dir)

def get_install_lsp_proxy_cmd():
    """Returns cmd to install language server proxy"""
    return get_container_cmd("npm i -g jsonrpc-ws-proxy@0.0.5")

def get_run_lsp_proxy_cmd(data_dir):
    """Starts websocket language server proxy"""
    return get_container_cmd("npx jsonrpc-ws-proxy --languageServers={}/shell_scripts.servers.yml"\
        .format(data_dir))

def get_hide_apps_cmd():
    """Returns cmd string to delete unneeded .desktop files from build container"""
    return 'libertine-container-manager exec -i {} -c \
        "bash -c \'for app in /usr/share/applications/*.desktop; do grep -q NoDisplay $app || echo NoDisplay=true >> $app; done\'"'\
        .format(CONTAINER_ID)

def patch_env():
    """
    Sets TMPDIR var to existing /tmp directory.
    Prevents issues with various Libertine commands
    """
    environ['TMPDIR'] = '/tmp'
    environ['LD_PRELOAD'] = ''
