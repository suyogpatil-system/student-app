#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Download and install Minikube
echo "Downloading Minikube..."
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
echo "Minikube installed successfully."

# Start Minikube with 4 nodes in a multi-node cluster
echo "Starting Minikube with 4 nodes..."
minikube start --nodes 4 -p multinode-k8s

# Wait for nodes to be ready
echo "Waiting for nodes to be ready..."
sleep 10  # Allow some time for nodes to initialize

# List all nodes and dynamically assign labels
echo "Labelling nodes..."
NODES=$(kubectl get nodes --no-headers -o custom-columns=":metadata.name")

# Iterate over the nodes and apply labels
INDEX=0
for NODE in $NODES; do
  if [ $INDEX -eq 1 ]; then
    kubectl label node "$NODE" node-role.kubernetes.io/worker=worker type=application --overwrite
    echo "Labeled $NODE as application"
  elif [ $INDEX -eq 2 ]; then
    kubectl label node "$NODE" node-role.kubernetes.io/worker=worker type=database --overwrite
    echo "Labeled $NODE as database"
  elif [ $INDEX -eq 3 ]; then
    kubectl label node "$NODE" node-role.kubernetes.io/worker=worker type=dependent_services --overwrite
    echo "Labeled $NODE as dependent_services"
  fi
  INDEX=$((INDEX + 1))
done

echo "Node labelling completed successfully."
