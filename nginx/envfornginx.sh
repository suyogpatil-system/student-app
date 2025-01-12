#!/bin/bash

# Check if envsubst is available
if ! command -v envsubst &> /dev/null; then
    echo "envsubst is not installed. Installing gettext..."
    sudo apt update
    sudo apt install -y gettext
else
    echo "envsubst is already installed."
fi


# Find private IP
SERVER_PRIVATE_IP=$(hostname -I | awk '{print $1}')
echo "Detected Private IP: $SERVER_PRIVATE_IP"

# Export the private IP to be used by envsubst
export SERVER_PRIVATE_IP

# Replace the variable in the Nginx configuration template
envsubst '${SERVER_PRIVATE_IP}' < nginx/nginx.template.conf > nginx.conf
