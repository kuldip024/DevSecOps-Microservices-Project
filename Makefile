.PHONY: help build push deploy logs clean test

# Variables
REGISTRY ?= docker.io
REGISTRY_USERNAME ?= your-username
IMAGE_TAG ?= latest
NAMESPACE ?= devsecops
KUBECONFIG ?= ~/.kube/config

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Display this help screen
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  DevSecOps Project - Makefile$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-30s$(NC) %s\n", $$1, $$2}'
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"

# Local Development
.PHONY: dev-up dev-down dev-logs

dev-up: ## Start services locally with Docker Compose
	@echo "$(GREEN)Starting services with Docker Compose...$(NC)"
	docker-compose up --build

dev-down: ## Stop all services
	@echo "$(GREEN)Stopping services...$(NC)"
	docker-compose down

dev-logs: ## View logs from all services
	@echo "$(GREEN)Displaying logs...$(NC)"
	docker-compose logs -f

# Building Docker Images
.PHONY: build build-user build-product build-frontend

build: build-user build-product build-frontend ## Build all Docker images

build-user: ## Build User Service image
	@echo "$(GREEN)Building User Service...$(NC)"
	docker build -t devsecops/user-service:$(IMAGE_TAG) services/user-service/
	@echo "$(GREEN)✓ User Service built$(NC)"

build-product: ## Build Product Service image
	@echo "$(GREEN)Building Product Service...$(NC)"
	docker build -t devsecops/product-service:$(IMAGE_TAG) services/product-service/
	@echo "$(GREEN)✓ Product Service built$(NC)"

build-frontend: ## Build Frontend image
	@echo "$(GREEN)Building Frontend...$(NC)"
	docker build -t devsecops/frontend:$(IMAGE_TAG) frontend-ui/
	@echo "$(GREEN)✓ Frontend built$(NC)"

# Pushing to Registry
.PHONY: push push-user push-product push-frontend

push: push-user push-product push-frontend ## Push all images to registry

push-user: build-user ## Push User Service to registry
	@echo "$(GREEN)Pushing User Service to registry...$(NC)"
	docker tag devsecops/user-service:$(IMAGE_TAG) $(REGISTRY)/devsecops/user-service:$(IMAGE_TAG)
	docker push $(REGISTRY)/devsecops/user-service:$(IMAGE_TAG)
	@echo "$(GREEN)✓ User Service pushed$(NC)"

push-product: build-product ## Push Product Service to registry
	@echo "$(GREEN)Pushing Product Service to registry...$(NC)"
	docker tag devsecops/product-service:$(IMAGE_TAG) $(REGISTRY)/devsecops/product-service:$(IMAGE_TAG)
	docker push $(REGISTRY)/devsecops/product-service:$(IMAGE_TAG)
	@echo "$(GREEN)✓ Product Service pushed$(NC)"

push-frontend: build-frontend ## Push Frontend to registry
	@echo "$(GREEN)Pushing Frontend to registry...$(NC)"
	docker tag devsecops/frontend:$(IMAGE_TAG) $(REGISTRY)/devsecops/frontend:$(IMAGE_TAG)
	docker push $(REGISTRY)/devsecops/frontend:$(IMAGE_TAG)
	@echo "$(GREEN)✓ Frontend pushed$(NC)"

# Kubernetes Operations
.PHONY: k8s-deploy k8s-delete k8s-status k8s-logs k8s-port-forward

k8s-deploy: ## Deploy to Kubernetes cluster
	@echo "$(GREEN)Creating namespace...$(NC)"
	kubectl create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	@echo "$(GREEN)Deploying services...$(NC)"
	kubectl apply -f k8s/
	@echo "$(GREEN)✓ Deployment completed$(NC)"

k8s-delete: ## Delete all Kubernetes resources
	@echo "$(RED)Deleting Kubernetes resources...$(NC)"
	kubectl delete -f k8s/ -n $(NAMESPACE) || true
	kubectl delete namespace $(NAMESPACE) || true
	@echo "$(RED)✓ Resources deleted$(NC)"

k8s-status: ## Show deployment status
	@echo "$(BLUE)Deployments:$(NC)"
	kubectl get deployments -n $(NAMESPACE)
	@echo "\n$(BLUE)Pods:$(NC)"
	kubectl get pods -n $(NAMESPACE)
	@echo "\n$(BLUE)Services:$(NC)"
	kubectl get services -n $(NAMESPACE)
	@echo "\n$(BLUE)Istio Resources:$(NC)"
	kubectl get virtualservices,gateways,destinationrules -n $(NAMESPACE)

k8s-logs: ## View logs from Kubernetes pods
	@echo "$(GREEN)Choose pod to view logs:$(NC)"
	@kubectl get pods -n $(NAMESPACE) -o name | sed 's|pod/||' | nl
	@read -p "Enter pod number: " POD_NUM; \
	POD_NAME=$$(kubectl get pods -n $(NAMESPACE) -o name | sed 's|pod/||' | sed -n "$${POD_NUM}p"); \
	kubectl logs -f $$POD_NAME -n $(NAMESPACE)

k8s-port-forward: ## Forward ports for local access
	@echo "$(GREEN)Port forwarding services...$(NC)"
	kubectl port-forward svc/frontend 3000:3000 -n $(NAMESPACE) &
	kubectl port-forward svc/user-service 3001:3001 -n $(NAMESPACE) &
	kubectl port-forward svc/product-service 3002:3002 -n $(NAMESPACE) &
	@echo "$(GREEN)✓ Services available at:$(NC)"
	@echo "  - Frontend: http://localhost:3000"
	@echo "  - User Service: http://localhost:3001"
	@echo "  - Product Service: http://localhost:3002"

# Istio Operations
.PHONY: istio-install istio-status istio-dashboard

istio-install: ## Install Istio on cluster
	@echo "$(GREEN)Installing Istio...$(NC)"
	curl -L https://istio.io/downloadIstio | sh -
	cd istio-* && ./bin/istioctl install --set profile=demo -y
	@echo "$(GREEN)✓ Istio installed$(NC)"

istio-status: ## Check Istio status
	@echo "$(BLUE)Istio Version:$(NC)"
	istioctl version
	@echo "\n$(BLUE)Istio Components:$(NC)"
	kubectl get pods -n istio-system

istio-dashboard: ## Open Kiali dashboard
	@echo "$(GREEN)Opening Kiali dashboard...$(NC)"
	istioctl dashboard kiali

# ArgoCD Operations
.PHONY: argocd-install argocd-password argocd-ui

argocd-install: ## Install ArgoCD
	@echo "$(GREEN)Installing ArgoCD...$(NC)"
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "$(GREEN)✓ ArgoCD installed$(NC)"

argocd-password: ## Get ArgoCD admin password
	@echo "$(GREEN)ArgoCD Admin Password:$(NC)"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

argocd-ui: ## Port-forward to ArgoCD UI
	@echo "$(GREEN)Opening ArgoCD UI...$(NC)"
	kubectl port-forward svc/argocd-server -n argocd 8080:443

# Testing
.PHONY: test test-user test-product

test: test-user test-product ## Run all tests

test-user: ## Test User Service
	@echo "$(GREEN)Testing User Service...$(NC)"
	cd services/user-service && npm test || true

test-product: ## Test Product Service
	@echo "$(GREEN)Testing Product Service...$(NC)"
	cd services/product-service && npm test || true

# Cleanup
.PHONY: clean clean-docker clean-k8s

clean: clean-docker clean-k8s ## Clean everything

clean-docker: ## Remove Docker images and containers
	@echo "$(RED)Cleaning Docker resources...$(NC)"
	docker-compose down -v
	docker rmi devsecops/user-service:$(IMAGE_TAG) || true
	docker rmi devsecops/product-service:$(IMAGE_TAG) || true
	docker rmi devsecops/frontend:$(IMAGE_TAG) || true
	@echo "$(GREEN)✓ Docker resources cleaned$(NC)"

clean-k8s: ## Delete Kubernetes namespace
	@echo "$(RED)Cleaning Kubernetes resources...$(NC)"
	kubectl delete namespace $(NAMESPACE) || true
	@echo "$(GREEN)✓ Kubernetes resources cleaned$(NC)"

# Utility
.PHONY: check-deps validate-manifests

check-deps: ## Check if required tools are installed
	@echo "$(BLUE)Checking dependencies...$(NC)"
	@command -v docker >/dev/null 2>&1 && echo "$(GREEN)✓ Docker$(NC)" || echo "$(RED)✗ Docker$(NC)"
	@command -v docker-compose >/dev/null 2>&1 && echo "$(GREEN)✓ Docker Compose$(NC)" || echo "$(RED)✗ Docker Compose$(NC)"
	@command -v kubectl >/dev/null 2>&1 && echo "$(GREEN)✓ kubectl$(NC)" || echo "$(RED)✗ kubectl$(NC)"
	@command -v istioctl >/dev/null 2>&1 && echo "$(GREEN)✓ istioctl$(NC)" || echo "$(RED)✗ istioctl$(NC)"
	@command -v argocd >/dev/null 2>&1 && echo "$(GREEN)✓ argocd$(NC)" || echo "$(RED)✗ argocd$(NC)"

validate-manifests: ## Validate Kubernetes manifests
	@echo "$(GREEN)Validating Kubernetes manifests...$(NC)"
	kubectl apply -f k8s/ --dry-run=client
	@echo "$(GREEN)✓ Manifests are valid$(NC)"

.DEFAULT_GOAL := help