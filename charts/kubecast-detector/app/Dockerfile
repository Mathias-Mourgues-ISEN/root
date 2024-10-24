# Utilise une image Python légère
FROM python:3.9-slim

# Installer les dépendances nécessaires
RUN pip install kubernetes
RUN pip install flask

# Copier ton code dans le conteneur
COPY detect_services.py /app/detect_services.py

# Définir le répertoire de travail
WORKDIR /app

EXPOSE 5000

# Commande à exécuter lorsque le conteneur démarre
CMD ["python", "detect_services.py"]
