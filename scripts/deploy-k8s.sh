#!/bin/bash

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="devsecops"
ISTIO_VERSION="1.15"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  DevSecOps Kubernetes Deployment Script                  ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check prerequisites
check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    
    local missing_tools=()
    
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    fi
    
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${RED}✗ Missing tools: ${missing_tools[@]}${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All prerequisites met${NC}"
}

# Check Kubernetes cluster
check_cluster() {
    echo -e "${BLUE}Checking Kubernetes cluster...${NC}"
    
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}✗ Cannot connect to Kubernetes cluster${NC}"
        exit 1
    fi
    
    CONTEXT=$(kubectl config current-context)
    echo -e "${GREEN}✓ Connected to cluster: $CONTEXT${NC}"
}

# Create namespace
create_namespace() {
    echo -e "${BLUE}Creating namespace...${NC}"
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    echo -e "${GREEN}✓ Namespace '$NAMESPACE' created${NC}"
}

# Install Istio
install_istio() {
    read -p "Do you want to install Istio? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Installing Istio ${ISTIO_VERSION}...${NC}"
        
        curl -L https://istio.io/downloadIstio | sh -
        cd istio-* || exit
        export PATH=$PWD/bin:$PATH
        
        istioctl install --set profile=demo -y
        
        echo -e "${BLUE}Enabling sidecar injection for namespace...${NC}"
        kubectl label namespace $NAMESPACE istio-injection=enabled --overwrite
        
        cd ..
        echo -e "${GREEN}✓ Istio installed${NC}"
    fi
}

# Build Docker images
build_images() {
    echo -e "${BLUE}Building Docker images...${NC}"
    
    docker build -t devsecops/user-service:latest services/user-service/
    docker build -t devsecops/product-service:latest services/product-service/
    docker build -t devsecops/frontend:latest frontend-ui/
    
    echo -e "${GREEN}✓ Docker images built${NC}"
}

# Deploy services
deploy_services() {
    echo -e "${BLUE}Deploying services...${NC}"
    
    kubectl apply -f k8s/user-service.yaml
    kubectl apply -f k8s/product-service.yaml
    kubectl apply -f k8s/frontend.yaml
    kubectl apply -f k8s/istio-config.yaml
    
    echo -e "${GREEN}✓ Services deployed${NC}"
}

# Wait for deployments
wait_for_deployments() {
    echo -e "${BLUE}Waiting for deployments to be ready...${NC}"
    
    kubectl wait --for=condition=available --timeout=300s \
        deployment/user-service deployment/product-service deployment/frontend \
        -n $NAMESPACE
    
    echo -e "${GREEN}✓ All deployments are ready${NC}"
}

# Display status
show_status() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Deployment Status${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    
    echo -e "${YELLOW}Deployments:${NC}"
    kubectl get deployments -n $NAMESPACE
    
    echo ""
    echo -e "${YELLOW}Pods:${NC}"
    kubectl get pods -n $NAMESPACE
    
    echo ""
    echo -e "${YELLOW}Services:${NC}"
    kubectl get services -n $NAMESPACE
    
    echo ""
    echo -e "${YELLOW}Istio Resources:${NC}"
    kubectl get virtualservices,gateways,destinationrules -n $NAMESPACE
}

# Get access information
show_access_info() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Access Information${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    
    INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    
    if [ -z "$INGRESS_IP" ]; then
        INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    fi
    
    if [ -z "$INGRESS_IP" ]; then
        echo -e "${YELLOW}Note: Ingress IP not yet assigned (may be pending for cloud providers)${NC}"
        echo "Using port-forward instead:"
        echo ""
        echo -e "${GREEN}Port Forward Commands:${NC}"
        echo "  kubectl port-forward svc/frontend 3000:3000 -n $NAMESPACE"
        echo "  kubectl port-forward svc/user-service 3001:3001 -n $NAMESPACE"
        echo "  kubectl port-forward svc/product-service 3002:3002 -n $NAMESPACE"
    else
        echo -e "${GREEN}Ingress IP: $INGRESS_IP${NC}"
        echo "  Frontend: http://$INGRESS_IP"
    fi
}

# Main execution
main() {
    check_prerequisites
    check_cluster
    create_namespace
    install_istio
    build_images
    deploy_services
    wait_for_deployments
    show_status
    show_access_info
    
    echo ""
    echo -e "${GREEN}✓ Deployment completed successfully!${NC}"
}

# Run main function
main