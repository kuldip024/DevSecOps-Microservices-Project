#!/bin/bash

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  DevSecOps Project - Git Setup Script                    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git is not installed${NC}"
    exit 1
fi

# Get repository URL
read -p "Enter your GitHub repository URL (https://github.com/username/repo.git): " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo -e "${RED}✗ Repository URL is required${NC}"
    exit 1
fi

# Initialize git repository
echo -e "${BLUE}Initializing Git repository...${NC}"
git init
git add .
git commit -m "Initial commit: DevSecOps project setup"

# Add remote
echo -e "${BLUE}Adding remote repository...${NC}"
git remote add origin "$REPO_URL"

# Create main branch and push
echo -e "${BLUE}Creating and pushing to main branch...${NC}"
git branch -M main
git push -u origin main

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Repository successfully initialized and pushed${NC}"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo "  1. Configure Jenkins with this repository"
    echo "  2. Update ArgoCD to point to: $REPO_URL"
    echo "  3. Set up webhook for automatic deployments"
else
    echo -e "${RED}✗ Failed to push to repository${NC}"
    echo "Make sure you have proper credentials configured"
    exit 1
fi

# Create branches for GitFlow
echo ""
echo -e "${BLUE}Creating GitFlow branches...${NC}"
git checkout -b develop
git push -u origin develop
git checkout -b release/v1.0
git push -u origin release/v1.0
git checkout main

echo -e "${GREEN}✓ GitFlow branches created${NC}"
echo ""
echo -e "${GREEN}Repository is ready for CI/CD!${NC}"