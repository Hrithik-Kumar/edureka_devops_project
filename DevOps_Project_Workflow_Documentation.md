# End-to-End DevOps Workflow Documentation

## Overview

This document describes the complete DevOps workflow implemented for a Java web application, covering CI/CD with Jenkins, Docker image build and push for linux/amd64, automated deployment with Ansible, and AWS EC2 configuration for public access.

---

## 1. Jenkins Pipeline: Build, Tag, and Push Docker Image

- **Pipeline Stages:**
  - **Build & Test Application:** Maven is used to build and package the Java application.
  - **Build Docker Image:**
    - Uses `docker buildx build --platform linux/amd64 -t <image:tag> --load .` to build a Docker image for the linux/amd64 architecture and load it into the local Docker daemon.
    - This ensures compatibility with AWS EC2 (which is linux/amd64).
    - Cleans up old buildkit containers after build.
  - **Push Docker Image to Hub:**
    - Logs in to Docker Hub using Jenkins credentials.
    - Pushes the versioned image (`docker push <image:tag>`).
    - Tags the image as `latest` and pushes the `latest` tag.
    - Logs out from Docker Hub.
  - **Deploy as Container:**
    - Stops and removes any existing container named `xyz-webapp-container`.
    - Runs the new container, mapping port 8090 on the host to 8080 in the container.

---

## 2. Ansible Deployment

- **Playbook:** `deploy-app-docker.yaml`
- **Steps:**
  - Ensures any old container is stopped and removed (ignores errors if not present).
  - Pulls the latest Docker image from Docker Hub.
  - Runs the new container with the correct port mapping (`8090:8080`).

---

## 3. AWS EC2 Security Group Configuration

- **Inbound Rules:**
  - TCP port 22 open for SSH.
  - TCP port 8090 open for public access to the web application.
- **Why:** Without opening port 8090, the application would not be accessible from outside AWS.

---

## 4. End-to-End Test

- After deployment, verified the application is running and accessible at:
  ```
  http://<EC2-PUBLIC-IP>:8090/
  ```
- Used `curl` to confirm connectivity.

---

## 5. Key Decisions & Best Practices

- **Separation of Concerns:** Build and push steps are separated in Jenkins for clarity and security.
- **Multi-Arch Build:** Used Docker Buildx to ensure the image is compatible with AWS EC2 (linux/amd64).
- **Automated Cleanup:** Buildkit containers are cleaned up after each build.
- **Idempotent Ansible Playbooks:** Playbooks handle missing containers gracefully.
- **Security:** Docker Hub credentials are only used in the push stage; AWS security group is configured for least privilege.

---

## 6. Kubernetes on AWS EKS

### 6.1. EKS Cluster Setup

**Tools installed:**

- AWS CLI: Used to interact with AWS services from the command line.
- eksctl: The official CLI for creating and managing EKS clusters.

**Steps:**

1. **Install AWS CLI v2**

   - Download and install the AWS CLI for Linux.
   - Verify installation with `aws --version`.

2. **Install eksctl**

   - Download and install eksctl for Linux.
   - Verify installation with `eksctl version`.

3. **Configure AWS CLI**

   - Run `aws configure` and enter your AWS Access Key, Secret Key, region, and output format.

4. **Create EKS Cluster**

   - Run:
     ```
     eksctl create cluster \
       --name devops-eks-cluster \
       --region us-east-1 \
       --nodes 2 \
       --node-type t3.medium \
       --with-oidc \
       --ssh-access \
       --ssh-public-key <your-ssh-key-name> \
       --managed
     ```
   - eksctl will automatically provision the EKS control plane and worker nodes (EC2 instances).
   - Use your existing EC2 key pair name for SSH access.

5. **Update kubeconfig and verify cluster**
   - Run:
     ```
     aws eks --region us-east-1 update-kubeconfig --name devops-eks-cluster
     kubectl get nodes
     ```
   - This configures kubectl to connect to your new EKS cluster and verifies the worker nodes are ready.

### 6.2. Deploying to EKS

**Kubernetes Manifests:**

- `k8s/deployment.yaml` — Defines a Deployment with 3 pods running the Java app Docker image.
- `k8s/service.yaml` — Defines a LoadBalancer Service to expose the app to the internet.

**Steps:**

1. Apply the manifests:
   ```
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   ```
2. Check status:

   ```
   kubectl get pods
   kubectl get svc
   ```

   - Wait for all pods to be in "Running" state.
   - The service will show an `EXTERNAL-IP` (public AWS ELB address).

3. Test the application:
   - Open the EXTERNAL-IP in your browser or use `curl`:
     ```
     curl http://<EXTERNAL-IP>
     ```
   - You should see your Java web application running.

---

## 7. Monitoring with Prometheus and Grafana on EKS

**Purpose:**
To provide real-time monitoring and observability for your EKS cluster and Java application.

**Steps:**
1. **Install Helm (Kubernetes package manager):**
   ```bash
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   helm version
   ```

2. **Add Prometheus Community Helm repo:**
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   ```

3. **Install kube-prometheus-stack (Prometheus + Grafana):**
   ```bash
   helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
   ```

4. **Access Grafana dashboard:**
   - Wait for all pods in the `monitoring` namespace to be running:
     ```bash
     kubectl get pods -n monitoring
     ```
   - Port-forward Grafana to your local machine:
     ```bash
     kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
     ```
   - Open [http://localhost:3000](http://localhost:3000) in your browser.
   - Default login:
     Username: `admin`
     Password: `prom-operator`

5. **Explore dashboards:**
   - Use the "Dashboards" menu in Grafana to view cluster, node, and pod metrics.
   - Pre-built dashboards provide insights into CPU, memory, pod health, and more.

**Best Practices:**
- For production or sharing, expose Grafana with a LoadBalancer service for a public URL.
- Secure access with authentication and network policies.

---

**This workflow demonstrates a robust, production-grade DevOps pipeline for Java applications using Jenkins, Docker, Ansible, AWS, Kubernetes (EKS), and integrated monitoring with Prometheus and Grafana.**
