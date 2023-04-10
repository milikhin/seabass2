# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")
cd $SCRIPTPATH
git clone https://github.com/milikhin/jsonrpc-ws-proxy.git
cd jsonrpc-ws-proxy
npm i
npm run build
