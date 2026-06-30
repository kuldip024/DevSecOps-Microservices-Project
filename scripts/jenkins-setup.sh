#!/bin/bash

# Jenkins Setup Guide Script

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Jenkins Setup and Configuration Guide                   ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Install Jenkins (Docker)
install_jenkins_docker() {
    echo -e "${BLUE}Installing Jenkins using Docker...${NC}"
    
    docker run -d \
        -p 8080:8080 \
        -p 50000:50000 \
        -v jenkins_home:/var/jenkins_home \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --name jenkins \
        --restart unless-stopped \
        jenkins/jenkins:lts
    
    echo -e "${GREEN}✓ Jenkins container started${NC}"
    
    sleep 10
    
    INITIAL_PASSWORD=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)
    
    echo ""
    echo -e "${YELLOW}Initial Admin Password:${NC}"
    echo "$INITIAL_PASSWORD"
    echo ""
    echo -e "${BLUE}Jenkins available at: http://localhost:8080${NC}"
}

# Display Jenkins setup steps
show_setup_steps() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Jenkins Setup Steps${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}1. Initial Setup${NC}"
    echo "   - Go to http://localhost:8080"
    echo "   - Enter the admin password (displayed above)"
    echo "   - Install suggested plugins"
    echo ""
    
    echo -e "${YELLOW}2. Required Plugins${NC}"
    echo "   - Manage Jenkins → Manage Plugins → Available"
    echo "   - Install these plugins:"
    echo "     • Docker plugin"
    echo "     • Docker Pipeline"
    echo "     • GitHub Integration"
    echo "     • Pipeline"
    echo "     • SonarQube Scanner"
    echo ""
    
    echo -e "${YELLOW}3. Configure Docker${NC}"
    echo "   - Manage Jenkins → Configure System"
    echo "   - Add Docker configuration:"
    echo "     • Docker Cloud → Docker Host URI: unix:///var/run/docker.sock"
    echo ""
    
    echo -e "${YELLOW}4. Configure Credentials${NC}"
    echo "   - Manage Jenkins → Manage Credentials"
    echo "   - Create Docker Registry credentials:"
    echo "     • Kind: Username with password"
    echo "     • Username: your-registry-username"
    echo "     • Password: your-registry-password"
    echo "     • ID: docker-registry"
    echo ""
    
    echo -e "${YELLOW}5. Create Pipeline Job${NC}"
    echo "   - New Item → Pipeline"
    echo "   - Name: devsecops-pipeline"
    echo "   - Configuration:"
    echo "     • Definition: Pipeline script from SCM"
    echo "     • SCM: Git"
    echo "     • Repository URL: https://github.com/yourusername/devsecops-project.git"
    echo "     • Branch: */main"
    echo "     • Script Path: ci/Jenkinsfile"
    echo ""
    
    echo -e "${YELLOW}6. Configure Build Parameters${NC}"
    echo "   - In pipeline job, enable 'This project is parameterized'"
    echo "   - Add parameters:"
    echo "     • REGISTRY (choice): docker.io, ghcr.io, quay.io"
    echo "     • REGISTRY_USERNAME (string)"
    echo "     • REGISTRY_PASSWORD (password)"
    echo ""
    
    echo -e "${YELLOW}7. GitHub Integration (Optional)${NC}"
    echo "   - Create GitHub Personal Access Token"
    echo "   - Manage Jenkins → Configure System → GitHub"
    echo "   - Add credentials and test connection"
    echo ""
    
    echo -e "${YELLOW}8. Webhook Setup (Optional)${NC}"
    echo "   - GitHub repo → Settings → Webhooks"
    echo "   - Payload URL: http://your-jenkins-url/github-webhook/"
    echo "   - Content type: application/json"
    echo "   - Events: Push events"
    echo ""
}

# Show Jenkinsfile explanation
explain_jenkinsfile() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Jenkinsfile Pipeline Stages${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}🔍 Checkout${NC}"
    echo "   Clones the Git repository"
    echo ""
    
    echo -e "${YELLOW}🐳 Build Images${NC}"
    echo "   Builds Docker images for all three services"
    echo ""
    
    echo -e "${YELLOW}🔒 Security Scan${NC}"
    echo "   Scans Docker images for vulnerabilities (Trivy)"
    echo ""
    
    echo -e "${YELLOW}📊 Code Quality${NC}"
    echo "   Runs code quality checks (SonarQube ready)"
    echo ""
    
    echo -e "${YELLOW}📤 Push Images${NC}"
    echo "   Pushes images to Docker registry (main branch only)"
    echo ""
    
    echo -e "${YELLOW}📋 Update ArgoCD${NC}"
    echo "   Triggers ArgoCD sync for automatic deployment"
    echo ""
    
    echo -e "${YELLOW}✅ Notify${NC}"
    echo "   Sends build completion notifications"
    echo ""
}

# Environment variables
show_env_vars() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Environment Variables for Pipeline${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}Jenkins Environment:${NC}"
    echo "  BUILD_NUMBER: Unique build identifier"
    echo "  BUILD_URL: Link to build page"
    echo "  GIT_BRANCH: Current Git branch"
    echo "  GIT_COMMIT: Latest commit hash"
    echo ""
    
    echo -e "${YELLOW}Custom Variables (in Jenkinsfile):${NC}"
    echo "  REGISTRY: Docker registry URL"
    echo "  REGISTRY_USERNAME: Registry login username"
    echo "  REGISTRY_PASSWORD: Registry login password"
    echo "  DOCKER_BUILDKIT: Enable BuildKit for faster builds"
    echo "  GIT_COMMIT_SHORT: Short commit hash"
    echo "  BUILD_DATE: Build timestamp"
    echo ""
}

# Troubleshooting
show_troubleshooting() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}Troubleshooting${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}Docker not found in Jenkins${NC}"
    echo "  Solution: Mount /var/run/docker.sock to Jenkins container"
    echo "  docker run ... -v /var/run/docker.sock:/var/run/docker.sock ..."
    echo ""
    
    echo -e "${YELLOW}Permission denied accessing Docker socket${NC}"
    echo "  Solution: Add jenkins user to docker group or use rootless Docker"
    echo "  docker exec jenkins usermod -aG docker jenkins"
    echo ""
    
    echo -e "${YELLOW}Build fails with 'git: command not found'${NC}"
    echo "  Solution: Git is required in the Jenkinsfile"
    echo "  Use: GIT_COMMIT_SHORT = sh(script: '...')"
    echo ""
    
    echo -e "${YELLOW}Images not pushing to registry${NC}"
    echo "  Solution: Check registry credentials in Manage Credentials"
    echo "  Verify credentials ID in Jenkinsfile"
    echo ""
    
    echo -e "${YELLOW}ArgoCD sync not triggering${NC}"
    echo "  Solution: Configure ArgoCD API token in Jenkins secrets"
    echo "  Uncomment and configure ArgoCD section in Jenkinsfile"
    echo ""
}

# Main menu
main() {
    echo ""
    read -p "Install Jenkins with Docker? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_jenkins_docker
    fi
    
    show_setup_steps
    explain_jenkinsfile
    show_env_vars
    show_troubleshooting
    
    echo ""
    echo -e "${GREEN}✓ Jenkins setup guide completed!${NC}"
    echo ""
}

main