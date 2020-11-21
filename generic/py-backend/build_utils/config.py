"""Container's options"""

CONTAINER_ID = 'seabass2-build'
CONTAINER_NAME = 'Seabass2 build container'
PACKAGES = [
    # 1. to install clickable
    'python3-pip',

    # 2. cause why not?
    'nano',
    'git',

    # 3. now this isn't great
    # but without these lines installation of qtbase5-private-dev would fail
    'libwayland-server0=1.12.0-1~ubuntu16.04.3',
    'libwayland-client0=1.12.0-1~ubuntu16.04.3',
    'libwayland-cursor0=1.12.0-1~ubuntu16.04.3',
    'qtchooser',

    # 4. finally, packages inspired by the clickable Docker image
    'build-essential',
    'cmake',
    'git',
    'gdb-multiarch',
    'gdbserver',
    'libc6-dbg',
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
    'libnotify-dev',
    'libtag1-dev',
    'libsmbclient-dev',
    'libpam0g-dev',
    'python3-requests',
    'python3-gnupg'
]
