#!/bin/bash
# Script pour mettre à jour et pousser les images Docker

docker login    

# Rebuild and push Docker image for monitoring-detector
cd ../charts/kubecast-detector/app/
docker build -t kubecast/kubecast-detector:latest .
docker push kubecast/kubecast-detector:latest

cd ../../web-app/app    
docker build -t kubecast/web-app:latest .
docker push kubecast/web-app:latest


