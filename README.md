# Industry Grade DevOps Project – Java Web Application

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

## 🚀 Overview

This project demonstrates a complete, industry-grade DevOps workflow for a Java web application, integrating CI/CD, containerization, automated deployment, Kubernetes orchestration, and real-time monitoring on AWS.

<!-- - **Live Demo:** [EKS Application URL](http://<EKS-EXTERNAL-IP>)
- **Grafana Dashboard:** [Grafana (if exposed)](http://<GRAFANA-EXTERNAL-IP>:3000)

--- -->

<!-- ## 🏗️ Architecture

![Architecture Diagram](./assets/architecture.png) -->

**Pipeline Flow:**

1. **Jenkins**: CI/CD pipeline (build, test, Dockerize, push, deploy)
2. **Docker Hub**: Container registry for versioned images
3. **Ansible**: Automated deployment to EC2 (staging)
4. **AWS EKS**: Production-grade Kubernetes cluster
5. **Prometheus & Grafana**: Monitoring and observability

---

## ✨ Features

- Automated build, test, and packaging with Maven
- Multi-arch Docker image build and push to Docker Hub
- Ansible playbooks for EC2 deployment
- Kubernetes manifests for EKS deployment (3 pods, LoadBalancer service)
- Jenkins pipeline with multi-environment deployment
- Real-time monitoring with Prometheus and Grafana

---

## 🛠️ Technology Stack

| Tool/Service | Purpose                  |
| ------------ | ------------------------ |
| Java (Maven) | Application & build tool |
| Jenkins      | CI/CD automation         |
| Docker       | Containerization         |
| Docker Hub   | Image registry           |
| Ansible      | Configuration management |
| AWS EC2      | Staging environment      |
| AWS EKS      | Kubernetes orchestration |
| Prometheus   | Metrics collection       |
| Grafana      | Monitoring dashboards    |

---

## 🚦 Quick Start

### Prerequisites

- AWS account with EKS and EC2 permissions
- Docker Hub account
- Jenkins server (with Docker, kubectl, AWS CLI, and kubeconfig for EKS)
- Ansible installed locally

### Setup Steps

1. **Clone the repository**

   ```bash
   git clone <repo-url>
   cd <project-directory>
   ```

2. **Configure Jenkins credentials and tools**

   - Set up Docker Hub credentials in Jenkins
   - Ensure Jenkins agent has Docker, kubectl, and AWS CLI

3. **Run the Jenkins pipeline**

   - Triggers build, Docker image push, EC2 deployment (Ansible), and EKS deployment

4. **Access the application**

   - EC2: `http://<EC2-PUBLIC-IP>:8090/`
   - EKS: `http://<EKS-EXTERNAL-IP>/`

5. **Access monitoring dashboards**
   - Port-forward Grafana: `kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80`
   - Open [http://localhost:3000](http://localhost:3000) (admin/prom-operator)

---

## 📚 Documentation

- [DevOps Project Workflow Documentation](./DevOps_Project_Workflow_Documentation.md)
- [Jenkinsfile](./Jenkinsfile)
- [Ansible Playbooks](./ansible/)
- [Kubernetes Manifests](./k8s/)

---

<!-- ## 📸 Screenshots & Visuals

> **Add your screenshots in the `assets/` folder and update the links below.**

- ![Jenkins Pipeline](./assets/jenkins-pipeline.png)
- ![EKS kubectl get pods](./assets/kubectl-get-pods.png)
- ![Application Running](./assets/app-screenshot.png)
- ![Grafana Dashboard](./assets/grafana-dashboard.png)
- ![Docker Hub Repo](./assets/docker-hub.png)
- ![AWS Console EKS](./assets/aws-eks.png)

--- -->

## 🤝 Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements.

---

## 📝 License

This project is licensed under the MIT License.

---

**Built with ❤️ by [Hrithik Kumar Advani]**
