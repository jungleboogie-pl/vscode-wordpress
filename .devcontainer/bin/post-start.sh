#!/bin/bash
sudo chown vscode:vscode /var/run/docker.sock; 
DEVCONTAINER_BIN=$(dirname "$0")
while ! "$DEVCONTAINER_BIN/fix-hosts.sh"; do
    echo "Failed to fix /etc/hosts. Retrying in 10 seconds..."
    sleep 10
done