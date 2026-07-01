# DevSecOps Microservices Project

A production-ready, secure microservices architecture demonstrating modern DevSecOps practices with automated CI/CD pipelines, Kubernetes orchestration, and Istio service mesh integration.

![GitHub Stars](https://img.shields.io/github/stars/yourusername/devsecops-project?style=social)
![License](https://img.shields.io/badge/license-MIT-blue)
![Node Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen)
![Kubernetes](https://img.shields.io/badge/kubernetes-1.24+-blue)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [API Documentation](#api-documentation)
- [Deployment](#deployment)
- [Technologies](#technologies)
- [Contributing](#contributing)
- [License](#license)

---

##  Overview

This project demonstrates a complete **DevSecOps pipeline** with:
- **Frontend**: React-based monitoring dashboard
- **Microservices**: Two independent Node.js/Express services
- **Containerization**: Multi-stage Docker builds with security best practices
- **Orchestration**: Kubernetes with Istio service mesh
- **CI/CD**: Jenkins automation and ArgoCD GitOps deployment
- **Security**: RBAC, mTLS, vulnerability scanning, and compliance

Perfect for learning DevSecOps, microservices architecture, and modern DevOps practices!

---

##  Features

###  Architecture
-  **Microservices Architecture** - Three independent services with clear separation of concerns
-  **Service Mesh** - Istio integration for traffic management, security, and observability
-  **Containerized** - Docker images optimized with multi-stage builds
-  **Orchestrated** - Kubernetes deployment with health checks and resource limits

###  Security
- **Non-root Containers** - Services run as non-root users
- **Read-only Filesystems** - Immutable container roots
- **mTLS Ready** - Automatic encryption between services via Istio
- **Security Scanning** - Trivy integration for vulnerability assessment
- **Network Policies** - Ready for Kubernetes network policies

###  CI/CD Automation
-  **Jenkins Pipeline** - Automated build, test, scan, and push
-  **ArgoCD** - GitOps-based continuous deployment
-  **Automated Rollback** - Instant rollback capability
-  **Multi-environment** - Dev, staging, and production ready

###  Observability
-  **Health Checks** - Liveness and readiness probes
-  **Metrics Ready** - Prometheus integration
-  **Tracing Ready** - Jaeger distributed tracing
-  **Logging** - Structured logging for all services

---`

---

## Quick Start

### Prerequisites
- Node.js 18+
- npm or yarn
- Docker (optional, for containerized deployment)
- Kubernetes cluster (optional, for K8s deployment)

### Local Development (3 Terminals)

**Terminal 1: User Service**
```bash
cd services/user-service
npm install
npm start
# Runs on http://localhost:3001
```

**Terminal 2: Product Service**
```bash
cd services/product-service
npm install
npm start
# Runs on http://localhost:3002
```

**Terminal 3: Frontend**
```bash
cd frontend-ui
npm install
npm start
# Runs on http://localhost:3000
```

### With Docker Compose (Single Command)
```bash
docker-compose up --build
# Access: http://localhost:3000
```

### Kubernetes Deployment
```bash
# Install Istio
kubectl apply -f k8s/
kubectl apply -f k8s/istio-config.yaml
```

---

## Project Structure

```
devsecops-project/
├── frontend-ui/                    # React Frontend (Port 3000)
│   ├── src/
│   │   ├── App.js                 # Main React component
│   │   ├── App.css                # Component styling
│   │   └── index.js               # Entry point
│   ├── public/
│   │   └── index.html             # HTML template
│   ├── package.json               # Dependencies
│   └── Dockerfile                 # Multi-stage build
│
├── services/
│   ├── user-service/              # User CRUD API (Port 3001)
│   │   ├── server.js              # Express server
│   │   ├── package.json
│   │   └── Dockerfile
│   │
│   └── product-service/           # Product CRUD API (Port 3002)
│       ├── server.js              # Express server
│       ├── package.json
│       └── Dockerfile
│
├── k8s/                           # Kubernetes Manifests
│   ├── user-service.yaml          # User service deployment
│   ├── product-service.yaml       # Product service deployment
│   ├── frontend.yaml              # Frontend deployment
│   ├── istio-config.yaml          # Istio configuration
│   └── kustomization.yaml         # Kustomize setup
│
├── ci/
│   └── Jenkinsfile                # Jenkins CI pipeline
│
├── cd/
│   └── argocd-app.yaml            # ArgoCD application
│
├── docker-compose.yml             # Local orchestration
├── Makefile                       # Development commands
└── README.md                      # This file
```

---

##  API Documentation

### User Service (Port 3001)

```bash
# Get all users
GET /api/users

# Create user
POST /api/users
Content-Type: application/json
{
  "name": "John Doe",
  "email": "john@example.com",
  "role": "user"
}

# Get user by ID
GET /api/users/:id

# Update user
PUT /api/users/:id

# Delete user
DELETE /api/users/:id

# Health check
GET /health
```

### Product Service (Port 3002)

```bash
# Get all products
GET /api/products

# Create product
POST /api/products
Content-Type: application/json
{
  "name": "Laptop",
  "price": 999.99,
  "category": "Electronics",
  "stock": 10
}

# Get product by ID
GET /api/products/:id

# Filter by category
GET /api/products/category/:category

# Update product
PUT /api/products/:id

# Delete product
DELETE /api/products/:id

# Health check
GET /health
```

---

##  Deployment

### Docker Compose (Development)
```bash
docker-compose up --build
```

### Kubernetes (Production)
```bash
# 1. Install prerequisites
kubectl create namespace devsecops
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm install istio istio/base -n istio-system
helm install istiod istio/istiod -n istio-system

# 2. Deploy services
kubectl apply -f k8s/
kubectl apply -f k8s/istio-config.yaml

# 3. Check deployment
kubectl get pods -n devsecops
kubectl get services -n devsecops
```

### CI/CD Pipeline

**1. Configure Jenkins**
- Create Pipeline job
- Repository: Your GitHub URL
- Script path: ci/Jenkinsfile

**2. Set up ArgoCD**
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f cd/argocd-app.yaml
```

**3. Push to GitHub**
```bash
git add .
git commit -m "Deploy DevSecOps platform"
git push origin main
```

---

##  Technologies Used

### Frontend
- **React 18** - UI framework
- **Axios** - HTTP client
- **CSS3** - Styling with responsive design

### Backend
- **Node.js 18** - Runtime
- **Express.js** - Web framework
- **Helmet.js** - Security headers
- **CORS** - Cross-origin resource sharing
- **UUID** - Unique identifiers

### DevOps & Infrastructure
- **Docker** - Containerization
- **Kubernetes** - Orchestration
- **Istio** - Service mesh
- **Jenkins** - CI/CD
- **ArgoCD** - GitOps deployment

### Monitoring & Observability (Ready)
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **Kiali** - Istio visualization
- **Jaeger** - Distributed tracing

---

##  Development Commands

```bash
# View all available commands
make help

# Build Docker images
make build

# Start local development
make dev-up

# Deploy to Kubernetes
make k8s-deploy

# View service status
make k8s-status

# Port forward services
make k8s-port-forward

# Clean everything
make clean
```

---

##  Contributing

Contributions are welcome! Here's how to get started:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Use consistent formatting
- Add comments for complex logic
- Follow security best practices
- Test before submitting PR


##  Troubleshooting

### Port Already in Use
```bash
# Find process using port
lsof -i :3000

# Kill it
kill -9 <PID>
```

### Services Not Communicating
```bash
# Check if services are running
curl http://localhost:3001/health
curl http://localhost:3002/health

# Check frontend logs (F12 → Console in browser)
```

### CORS Errors
- Ensure backend services are running
- Hard refresh browser (Ctrl+Shift+R)
- Check browser console for detailed errors

### Kubernetes Issues
```bash
# Check pod status
kubectl get pods -n devsecops

# View pod logs
kubectl logs <pod-name> -n devsecops

# Describe pod for events
kubectl describe pod <pod-name> -n devsecops
```


## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## About

This is a demonstration project showcasing modern DevSecOps practices including:
- Microservices architecture
- Container orchestration
- Automated CI/CD pipelines
- Security best practices
- Infrastructure as Code

Perfect for learning, portfolio building, and production deployments!

---

##  Acknowledgments

- Kubernetes community
- Istio project
- Jenkins community
- ArgoCD project
- Draw.io

---

##  Support & Contact

-  Email: [kuldipramavat34@gmail.com]
-  GitHub: [@kuldip024](https://github.com/kuldip024)


---

##  Quick Links

- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Istio Documentation](https://istio.io/latest/docs/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

---
