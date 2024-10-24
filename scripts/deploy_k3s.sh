#!/bin/bash
# Script to deploy all Helm charts on k3s

# Check if k3s is installed
if ! command -v k3s &> /dev/null; then
    echo "k3s is not installed. Installing..."
    curl -sfL https://get.k3s.io | sh -
    if [ $? -ne 0 ]; then
        echo "Error installing k3s."
        exit 1
    fi
    echo "k3s installed successfully."
else
    echo "k3s is already installed."
fi

# Verify if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "kubectl should be included with k3s, but is not found."
    exit 1
else
    echo "kubectl is available."
fi

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "Helm is not installed. Installing..."
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    if [ $? -ne 0 ]; then
        echo "Error installing Helm."
        exit 1
    fi
else
    echo "Helm is already installed."
fi

# Check if conntrack is installed
if ! command -v conntrack &> /dev/null; then
    echo "conntrack is not installed. Installing..."
    sudo apt install -y conntrack
    if [ $? -ne 0 ]; then
        echo "Error installing conntrack."
        exit 1
    fi
else
    echo "conntrack is already installed."
fi

# Create the monitoring namespace if it doesn't exist
kubectl get namespace monitoring &> /dev/null
if [ $? -ne 0 ]; then
    echo "Creating monitoring namespace..."
    kubectl create namespace monitoring
fi

# Create the kubecast namespace if it doesn't exist
kubectl get namespace kubecast &> /dev/null
if [ $? -ne 0 ]; then
    echo "Creating kubecast namespace..."
    kubectl create namespace kubecast
fi

# Update Helm repositories
echo "Updating Helm repositories..."
helm repo update

# Deploy Grafana using Helm
echo "Deploying Grafana..."
helm upgrade --install grafana ../charts/grafana --namespace monitoring
if [ $? -ne 0 ]; then
    echo "Error deploying Grafana."
    exit 1
fi

# Deploy Prometheus using Helm
echo "Deploying Prometheus..."
helm upgrade --install prometheus ../charts/prometheus --namespace monitoring
if [ $? -ne 0 ]; then
    echo "Error deploying Prometheus."
    exit 1
fi

# Deploy kubecast-detector using Helm
echo "Deploying kubecast-detector..."
helm upgrade --install kubecast-detector ../charts/kubecast-detector --namespace kubecast
if [ $? -ne 0 ]; then
    echo "Error deploying kubecast-detector."
    exit 1
fi

# Deploy web-app using Helm
echo "Deploying web-app..."
helm upgrade --install web-app ../charts/web-app --namespace kubecast
if [ $? -ne 0 ]; then
    echo "Error deploying web-app."
    exit 1
fi

echo "All deployments completed successfully."