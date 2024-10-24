from flask import Flask, jsonify
from kubernetes import client, config
import os

app = Flask(__name__)

# Load Kubernetes configuration
config.load_incluster_config()

@app.route('/service', methods=['GET'])
def index():
    return "API is running. Use /services to get monitoring services."

@app.route('/', methods=['GET'])
def list_images():
    try:
        # Initialize Kubernetes API client
        v1 = client.CoreV1Api()

        # Fetch list of all pods in the cluster
        pods = v1.list_pod_for_all_namespaces(watch=False)

        # Create a set to store unique images
        images = set()

        # Iterate over each pod and extract container images
        for pod in pods.items:
            for container in pod.spec.containers:
                images.add(container.image)

        # Convert set to list for JSON serialization
        return jsonify(list(images))

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv('PORT', 5000)))