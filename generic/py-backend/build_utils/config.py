"""Container's options"""

CONTAINER_ID = 'seabass2-build'
CONTAINER_NAME = 'Seabass2 build container'
PACKAGES = [
    # might be helpful
    'curl',
    'nano',
    'git',

    # inspired by the clickable Docker images
    'build-essential',
    'cmake',
    'pkg-config',
    'intltool',
    'ubuntu-sdk-libs-dev',

    'click',
    'click-reviewers-tools'
]
