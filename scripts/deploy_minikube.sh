#!/bin/bash
# Script pour déployer tous les charts Helm

# Vérifier si kubectl est installé
if ! command -v kubectl &> /dev/null; then
    echo "kubectl n'est pas installé. Installation en cours..."
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
    if [ $? -ne 0 ]; then
        echo "Erreur lors de l'installation de kubectl."
        exit 1
    fi
else
    echo "kubectl est déjà installé."
fi

# Vérifier si Helm est installé
if ! command -v helm &> /dev/null; then
    echo "Helm n'est pas installé. Installation en cours..."
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    if [ $? -ne 0 ]; then
        echo "Erreur lors de l'installation de Helm."
        exit 1
    fi
else
    echo "Helm est déjà installé."
fi

# Vérifier si Minikube est installé
if ! command -v minikube &> /dev/null; then
    echo "Minikube n'est pas installé. Veuillez l'installer avant de continuer."
    exit 1
fi

# Vérifier si conntrack est installé
if ! command -v conntrack &> /dev/null; then
    echo "conntrack n'est pas installé. Installation en cours..."
    sudo apt install -y conntrack
    if [ $? -ne 0 ]; then
        echo "Erreur lors de l'installation de conntrack."
        exit 1
    fi
else
    echo "conntrack est déjà installé."
fi

# Démarrer Minikube
minikube start

# Créer le namespace monitoring s'il n'existe pas
kubectl get namespace monitoring &> /dev/null
if [ $? -ne 0 ]; then
    echo "Création du namespace monitoring..."
    kubectl create namespace monitoring
fi

kubectl get namespace kubecast &> /dev/null
if [ $? -ne 0 ]; then
    echo "Création du namespace KubeCast..."
    kubectl create namespace kubecast
fi

# # Ajouter les dépôts Helm s'ils ne sont pas déjà ajoutés
# if ! helm repo list | grep -q "prometheus-community"; then
#     echo "Ajout du dépôt Helm Prometheus..."
#     helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# fi

# if ! helm repo list | grep -q "grafana"; then
#     echo "Ajout du dépôt Helm Grafana..."
#     helm repo add grafana https://grafana.github.io/helm-charts
# fi

# Mettre à jour les dépôts Helm
echo "Mise à jour des dépôts Helm..."
helm repo update

# Déployer Grafana avec Helm
echo "Déploiement de Grafana..."
helm upgrade --install grafana ../charts/grafana --namespace monitoring
if [ $? -ne 0 ]; then
    echo "Erreur lors du déploiement de Grafana."
    exit 1
fi

# Déployer Prometheus avec Helm
echo "Déploiement de Prometheus..."
helm upgrade --install prometheus ../charts/prometheus --namespace monitoring
if [ $? -ne 0 ]; then
    echo "Erreur lors du déploiement de Prometheus."
    exit 1
fi

# Déployer kubecast-detector avec Helm
echo "Déploiement de kubecast-detector..."
helm upgrade --install kubecast-detector ../charts/kubecast-detector --namespace kubecast
if [ $? -ne 0 ]; then
    echo "Erreur lors du déploiement de kubecast-detector."
    exit 1
fi

# Déployer web-app avec Helm
echo "Déploiement de web-app..."
helm upgrade --install web-app ../charts/web-app --namespace kubecast
if [ $? -ne 0 ]; then
    echo "Erreur lors du déploiement de web app."
    exit 1
fi

echo "Tous les déploiements ont été effectués avec succès."
