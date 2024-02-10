"""Container's options"""

CONTAINER_ID = 'seabass2'
CONTAINER_NAME = 'Seabass2 build container'
PACKAGES = [
    # might be helpful
    'curl',
    'nano',
    'git',
    'python3-pip',

    # clickable & build tools
    'build-essential',
    'cmake',
    'pkg-config',
    'intltool',
    'nodejs',
    'npm',
    'click',
    'click-reviewers-tools',
    'clickable',

    # lsp tools
    'clangd',

    # platform SDK
    'qtquickcontrols2-5-dev',
    'ubuntu-sdk-libs-dev'
]
