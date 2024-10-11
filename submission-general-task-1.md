# Story Node Automatic Installer

## How to Use

1. Download the script from [repository link](https://github.com/pom7516/story-node-setup/blob/master/install-story-node.sh).
2. Run the following command to install the Story node:
   ```bash
   # Update and install Go
sudo apt update && sudo apt upgrade -y && sudo rm -rf /usr/local/go && \
mkdir -p $HOME/go/bin && \
wget "https://golang.org/dl/go1.23.0.linux-amd64.tar.gz" -O go.tar.gz && \
sudo tar -C /usr/local -xzf go.tar.gz && \
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> ~/.bash_profile && \
source ~/.bash_profile && go version

# Download Story binaries
mkdir temp && cd temp && \
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.3-b224fdf.tar.gz && \
tar -xvzf geth-linux-amd64-0.9.3-b224fdf.tar.gz && \
mv geth $HOME/go/bin/story-geth && \
wget -q https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.10.1-57567e5.tar.gz && \
tar -xzf story-linux-amd64-0.10.1-57567e5.tar.gz && \
mv story $HOME/go/bin/story

# Initialize and set up systemd services
$HOME/go/bin/story init --network iliad
sudo tee /etc/systemd/system/story-geth.service <<EOF
[Unit]
Description=Story Geth Client
After=network.target
[Service]
User=root
ExecStart=/root/go/bin/story-geth --iliad --syncmode full
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
sudo tee /etc/systemd/system/story.service <<EOF
[Unit]
Description=Story Consensus Client
After=network.target
[Service]
User=root
ExecStart=/root/go/bin/story run
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

# Start services
sudo systemctl daemon-reload && \
sudo systemctl enable story-geth && sudo systemctl restart story-geth && \
sudo systemctl enable story && sudo systemctl restart story

# Check sync status
curl -s localhost:26657/status | jq && echo "Installation done!"

