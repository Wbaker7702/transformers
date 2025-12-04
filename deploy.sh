#!/bin/bash
# Production Deployment Script for HuggingFace Transformers
# This script handles deployment to PyPI (Test and Production)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PYPI_TEST_URL="https://test.pypi.org/legacy/"
PYPI_PROD_URL="https://upload.pypi.org/legacy/"
DIST_DIR="./dist"

echo -e "${GREEN}=== HuggingFace Transformers Production Deployment ===${NC}\n"

# Check if dist directory exists
if [ ! -d "$DIST_DIR" ]; then
    echo -e "${RED}Error: dist/ directory not found. Please build the package first.${NC}"
    exit 1
fi

# Check if distribution files exist
WHEEL_FILE=$(ls $DIST_DIR/*.whl 2>/dev/null | head -1)
SDIST_FILE=$(ls $DIST_DIR/*.tar.gz 2>/dev/null | head -1)

if [ -z "$WHEEL_FILE" ] || [ -z "$SDIST_FILE" ]; then
    echo -e "${RED}Error: Distribution files not found in $DIST_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}Found distribution files:${NC}"
echo "  - Wheel: $(basename $WHEEL_FILE)"
echo "  - Source: $(basename $SDIST_FILE)"
echo ""

# Validate packages with twine
echo -e "${YELLOW}Validating packages with twine...${NC}"
python3 -m twine check $DIST_DIR/* || {
    echo -e "${RED}Package validation failed!${NC}"
    exit 1
}
echo -e "${GREEN}✓ Package validation passed${NC}\n"

# Determine deployment target
if [ "$1" == "test" ]; then
    DEPLOY_TARGET="TestPyPI"
    REPO_URL="$PYPI_TEST_URL"
    REPO_FLAG="--repository-url=$PYPI_TEST_URL"
elif [ "$1" == "production" ] || [ "$1" == "prod" ]; then
    DEPLOY_TARGET="Production PyPI"
    REPO_URL="$PYPI_PROD_URL"
    REPO_FLAG=""
    
    # Warning for production
    echo -e "${RED}⚠️  WARNING: You are about to deploy to PRODUCTION PyPI!${NC}"
    echo -e "${YELLOW}This will make the package publicly available.${NC}\n"
    
    read -p "Are you sure you want to continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo -e "${YELLOW}Deployment cancelled.${NC}"
        exit 0
    fi
else
    echo -e "${YELLOW}Usage: $0 [test|production]${NC}"
    echo ""
    echo "  test        - Deploy to TestPyPI (recommended first step)"
    echo "  production  - Deploy to Production PyPI"
    echo ""
    echo "Example:"
    echo "  $0 test          # Deploy to TestPyPI"
    echo "  $0 production    # Deploy to Production PyPI"
    exit 1
fi

# Check for credentials
echo -e "${YELLOW}Checking for PyPI credentials...${NC}"
if [ -z "$TWINE_USERNAME" ] && [ -z "$TWINE_PASSWORD" ]; then
    echo -e "${YELLOW}TWINE_USERNAME and TWINE_PASSWORD not set.${NC}"
    echo -e "${YELLOW}Twine will prompt for credentials or use keyring.${NC}\n"
fi

# Deploy
echo -e "${GREEN}Deploying to $DEPLOY_TARGET...${NC}"
if [ "$1" == "test" ]; then
    python3 -m twine upload $DIST_DIR/* --repository-url="$PYPI_TEST_URL" --verbose
else
    python3 -m twine upload $DIST_DIR/* --verbose
fi

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Successfully deployed to $DEPLOY_TARGET!${NC}"
    
    if [ "$1" == "test" ]; then
        echo -e "\n${YELLOW}Next steps:${NC}"
        echo "1. Test installation: pip install -i https://test.pypi.org/simple/ transformers"
        echo "2. Verify functionality"
        echo "3. If everything works, deploy to production: $0 production"
    else
        echo -e "\n${GREEN}Package is now available on PyPI!${NC}"
        echo "Install with: pip install transformers"
    fi
else
    echo -e "\n${RED}✗ Deployment failed!${NC}"
    exit 1
fi
