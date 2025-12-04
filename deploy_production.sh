#!/bin/bash
# Production Deployment Script - Requires Credentials
# Usage: TWINE_USERNAME=__token__ TWINE_PASSWORD=your-token ./deploy_production.sh

set -e

export PATH="$HOME/.local/bin:$PATH"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  HuggingFace Transformers - Production Deployment          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check for credentials
if [ -z "$TWINE_USERNAME" ] || [ -z "$TWINE_PASSWORD" ]; then
    echo "❌ ERROR: PyPI credentials required!"
    echo ""
    echo "Please set environment variables:"
    echo "  export TWINE_USERNAME=__token__"
    echo "  export TWINE_PASSWORD=your-pypi-api-token"
    echo ""
    echo "Get your API token at: https://pypi.org/manage/account/token/"
    echo ""
    exit 1
fi

# Validate packages
echo "📦 Validating packages..."
python3 -m twine check dist/* || {
    echo "❌ Package validation failed!"
    exit 1
}
echo "✅ Packages validated"
echo ""

# Show what will be deployed
echo "📋 Packages to deploy:"
ls -lh dist/*.whl dist/*.tar.gz 2>/dev/null | awk '{print "   " $9 " (" $5 ")"}'
echo ""

# Confirm deployment
echo "⚠️  WARNING: This will deploy to PRODUCTION PyPI!"
echo "   Package will be publicly available."
echo ""
read -p "Continue with deployment? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled."
    exit 0
fi

# Deploy
echo ""
echo "🚀 Deploying to PyPI..."
python3 -m twine upload dist/* --verbose

if [ $? -eq 0 ]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  ✅ DEPLOYMENT SUCCESSFUL!                                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Package is now available on PyPI!"
    echo "Install with: pip install transformers"
    echo ""
    echo "View package: https://pypi.org/project/transformers/"
else
    echo ""
    echo "❌ Deployment failed!"
    exit 1
fi
