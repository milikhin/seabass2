curl -fsSL https://deb.nodesource.com/setup_20.x | bash

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 26B6105E1107D11E244625C4CD2E95CE2F98D3F7
echo deb https://ppa.launchpadcontent.net/bhdouglass/clickable/ubuntu focal main > /etc/apt/sources.list.d/clickable.list
echo deb-src https://ppa.launchpadcontent.net/bhdouglass/clickable/ubuntu focal main >> /etc/apt/sources.list.d/clickable.list
apt-get update
