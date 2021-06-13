"""Container's options"""

CONTAINER_ID = 'seabass2-build'
CONTAINER_NAME = 'Seabass2 build container'
PACKAGES = [
    # 1. required to install clickable
    'python3.6',
    'python3-pip',

    # 2. cause why not?
    'nano',
    'git',

    # 3. list of packages inspired by the clickable Docker image
    'build-essential',
    'cmake',
    'git',
    'g++',
    'libc-dev',
    'libicu-dev',
    'nodejs',
    'pkg-config',
    'qtbase5-private-dev',
    'qtdeclarative5-private-dev',
    'qtfeedback5-dev',
    'qtpositioning5-dev',
    'qtquickcontrols2-5-dev',
    'qtsystems5-dev',
    'qtwebengine5-dev',
    'libqt5opengl5-dev',
    'click',
    'click-reviewers-tools',
    'ubuntu-sdk-libs-dev',
    'ubuntu-sdk-libs-tools',
    'ubuntu-sdk-libs',
    'libconnectivity-qt1-dev',

    'tls-padding'
]
