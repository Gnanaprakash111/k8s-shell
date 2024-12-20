#!/bin/bash

# Define Variables
NAMESPACE="myapp-namespace1"
DEPLOYMENT="myapp-deployment"
SERVICE="myapp-service"
IMAGE="myapp-image:latest"

# Creating Kubernetes Namespace
echo "creating kubernetes namespace"
kubectl create namespace $NAMESPACE

# Apply ConfigMap
echo "creating configmap.."
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
  namespace: $NAMESPACE
data:
  APP_ENV: "production"
EOF

# Apply Deployment
echo "Creating Deployment.."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOYMENT
  namespace: $NAMESPACE
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp-container
        image: $IMAGE
        ports:
        - containerPort: 80
        envFrom:
        - configMapRef:
            name: myapp-config
EOF

# Apply Service
echo "Creating Service.."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE
  namespace: $NAMESPACE
spec:
  selector:
    app: myapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
EOF

echo "Deployment completed successfully!"

