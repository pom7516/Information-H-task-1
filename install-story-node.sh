#!/bin/bash

echo "Auto install Story node validator run"

# Update your system
sudo apt update && sudo apt upgrade -y

# Install Go lang
sudo rm -rf /usr/local/go
cd $HOME
mkdir -p go/bin
version="1.23.0"
rm "go$ver.linux-amd64.tar.gz"
wget "https://golang.org/dl/go$version.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf "go$version.linux-amd64.tar.gz"
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Download Story-Geth Binary file
mkdir temp
cd temp
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.3-b224fdf.tar.gz
tar -xvzf geth-linux-amd64-0.9.3-b224fdf.tar.gz
mv $HOME/temp/geth-linux-amd64-0.9.3-b224fdf/geth $HOME/go/bin/story-geth

# Download Story Binary file
wget -q https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.10.1-57567e5.tar.gz
tar -xzf story-linux-amd64-0.10.1-57567e5.tar.gz
mv $HOME/temp/story-linux-amd64-0.10.1-57567e5/story $HOME/go/bin/story

# Initialize Iliad
$HOME/go/bin/story init --network iliad

# Create systemd Service for Story-Geth
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth Client
After=network.target

[Service]
User=root
ExecStart=/root/go/bin/story-geth --iliad --syncmode full
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Create systemd Service for Story
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Consensus Client
After=network.target

[Service]
User=root
ExecStart=/root/go/bin/story run
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Enable and start geth
sudo systemctl daemon-reload
sudo systemctl enable story-geth
sudo systemctl restart story-geth && sudo journalctl -u story-geth -f

# Enable and start story
sudo systemctl daemon-reload
sudo systemctl enable story
sudo systemctl restart story && sudo journalctl -u story -f

# Check Sync Status
curl -s localhost:26657/status | jq

echo "Installation done! and wait for synce status false...."
