"""Container's options"""

CONTAINER_ID = 'seabass2'
CONTAINER_NAME = 'Seabass2 build container'
PACKAGES = [
    # might be helpful
    'curl',
    'nano',
    'git',

    # inspired by the clickable Docker images
    'build-essential',
    'clangd',
    'cmake',
    'pkg-config',
    'intltool',
    'nodejs',
    'click',
    'click-reviewers-tools',
    'clickable'

    # 'ubuntu-sdk-libs-dev'
]
