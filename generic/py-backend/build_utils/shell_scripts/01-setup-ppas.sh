mkdir -p /etc/apt/keyrings
# Download the new repository's GPG key and save it in the keyring directory
wget -O - -o /dev/null https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
# Add the new repository's source list with its GPG key for package verification
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >> /etc/apt/sources.list.d/nodesource.list

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 26B6105E1107D11E244625C4CD2E95CE2F98D3F7
echo deb https://ppa.launchpadcontent.net/bhdouglass/clickable/ubuntu focal main > /etc/apt/sources.list.d/clickable.list
echo deb-src https://ppa.launchpadcontent.net/bhdouglass/clickable/ubuntu focal main >> /etc/apt/sources.list.d/clickable.list
apt-get update
