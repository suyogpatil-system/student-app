#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Delete the Minikube cluster
echo "Deleting Minikube cluster..."
minikube delete -p multinode-k8s
echo "Minikube cluster deleted successfully."

# Remove Minikube binary
if [ -f /usr/local/bin/minikube ]; then
    echo "Removing Minikube binary..."
    sudo rm /usr/local/bin/minikube
    echo "Minikube binary removed successfully."
else
    echo "Minikube binary not found, skipping removal."
fi

# Check if any leftover Minikube files exist and remove them
echo "Cleaning up leftover Minikube files..."
rm -rf ~/.minikube ~/.kube
echo "Cleanup completed."

echo "All Minikube-related resources have been successfully deleted."
