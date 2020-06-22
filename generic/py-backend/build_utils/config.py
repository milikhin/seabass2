"""Container's options"""

CONTAINER_ID = 'seabass2-build'
CONTAINER_NAME = 'Seabass2 build container'
PACKAGES = ['python3-pip', # to install clickable
            'nano', # cause why not?
            'git',
            'qtchooser', # must be installed before qtbase5-private-dev

            'build-essential', # the list is inspired by clickable Docker image
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
            'python3-gnupg']
