# Quick Deployment Reference

## Current Status
✅ **Ready for Deployment**
- Package validated: PASSED
- Build artifacts: READY
- Security audit: PASSED
- Version: 4.48.0.dev0

## Quick Deploy Commands

### Test Deployment (Recommended First)
```bash
# Set credentials (if not using keyring)
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=your-testpypi-token

# Deploy to TestPyPI
./deploy.sh test
```

### Production Deployment
```bash
# Set credentials (if not using keyring)
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=your-pypi-token

# Deploy to Production PyPI
./deploy.sh production
```

### Manual Deployment
```bash
# TestPyPI
python3 -m twine upload dist/* --repository-url https://test.pypi.org/legacy/

# Production PyPI
python3 -m twine upload dist/*
```

## Pre-Flight Checks
```bash
# 1. Validate packages
python3 -m twine check dist/*

# 2. Verify package contents
ls -lh dist/

# 3. Test import
python3 -c "import sys; sys.path.insert(0, 'src'); import transformers; print(transformers.__version__)"
```

## Files Ready for Deployment
- `dist/transformers-4.48.0.dev0-py3-none-any.whl` (9.7 MB)
- `dist/transformers-4.48.0.dev0.tar.gz` (8.3 MB)

## Important Notes
⚠️ **Current version is a development version (4.48.0.dev0)**
- For production release, update version in `setup.py` to remove `.dev0`
- Test deployment on TestPyPI first before production

## Get PyPI Credentials
- **TestPyPI**: https://test.pypi.org/manage/account/token/
- **Production PyPI**: https://pypi.org/manage/account/token/

## After Deployment
```bash
# Test installation from TestPyPI
pip install -i https://test.pypi.org/simple/ transformers

# Test installation from Production PyPI
pip install transformers
```
