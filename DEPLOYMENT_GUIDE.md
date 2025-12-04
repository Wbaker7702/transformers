# Production Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying HuggingFace Transformers to production PyPI.

## ⚠️ Important Notes

1. **Version Check**: Current version is `4.48.0.dev0` (development version)
   - For production releases, use a release version (e.g., `4.48.0`) without `.dev0`
   - Update version in `setup.py` before production deployment

2. **Pre-Deployment Checklist**: Complete all items before deploying

## Pre-Deployment Checklist

### ✅ Completed
- [x] Security audit completed (no vulnerabilities found)
- [x] Build artifacts created and validated
- [x] Package validation passed (twine check)
- [x] Code quality checks passed
- [x] Dependencies updated and compatible

### ⚠️ Required Before Production
- [ ] **Version Update**: Change version from `4.48.0.dev0` to release version (e.g., `4.48.0`)
- [ ] **Tests**: Run full test suite and ensure all tests pass
- [ ] **Documentation**: Verify README and documentation are up to date
- [ ] **Release Notes**: Prepare release notes in RELEASE.md
- [ ] **Git Tag**: Create and push release tag (e.g., `v4.48.0`)
- [ ] **CI/CD**: Ensure CI/CD pipelines pass

## Deployment Steps

### Step 1: Update Version (if needed)

If deploying a development version to test, skip this step. For production release:

```bash
# Edit setup.py and change version from:
version="4.48.0.dev0"
# To:
version="4.48.0"
```

### Step 2: Rebuild Package (if version changed)

```bash
export PYTHONPATH=src
rm -rf dist build
python3 setup.py bdist_wheel sdist
```

### Step 3: Validate Package

```bash
# Check package validity
python3 -m twine check dist/*

# Verify package contents
unzip -l dist/*.whl | head -20
tar -tzf dist/*.tar.gz | head -20
```

### Step 4: Test Deployment (Recommended First)

Deploy to TestPyPI first to verify everything works:

```bash
# Make script executable
chmod +x deploy.sh

# Deploy to TestPyPI
./deploy.sh test
```

**Note**: You'll need TestPyPI credentials:
- Sign up at: https://test.pypi.org/account/register/
- Create API token at: https://test.pypi.org/manage/account/token/

### Step 5: Verify Test Installation

After TestPyPI deployment, verify the package works:

```bash
# Create a clean virtual environment
python3 -m venv test_env
source test_env/bin/activate

# Install from TestPyPI
pip install -i https://test.pypi.org/simple/ transformers

# Test basic functionality
python -c "from transformers import pipeline; print('Import successful')"
python -c "import transformers; print(f'Version: {transformers.__version__}')"
```

### Step 6: Production Deployment

Once TestPyPI deployment is verified:

```bash
# Deploy to Production PyPI
./deploy.sh production
```

**Note**: You'll need PyPI credentials:
- Sign up at: https://pypi.org/account/register/
- Create API token at: https://pypi.org/manage/account/token/

## Authentication Methods

### Method 1: Environment Variables (Recommended)

```bash
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
./deploy.sh production
```

### Method 2: Keyring (Secure)

```bash
# Store credentials in keyring
python3 -m keyring set https://upload.pypi.org/legacy/ __token__
# Enter your API token when prompted

# Deploy (will use keyring automatically)
./deploy.sh production
```

### Method 3: Interactive Prompt

If neither method is configured, twine will prompt for credentials.

## Manual Deployment Commands

If you prefer to deploy manually:

### TestPyPI
```bash
python3 -m twine upload dist/* \
  --repository-url https://test.pypi.org/legacy/ \
  --verbose
```

### Production PyPI
```bash
python3 -m twine upload dist/* --verbose
```

## Post-Deployment Verification

1. **Check PyPI**: Visit https://pypi.org/project/transformers/ (or TestPyPI equivalent)
2. **Install Test**: `pip install transformers` (or with `-i https://test.pypi.org/simple/` for test)
3. **Verify Version**: `python -c "import transformers; print(transformers.__version__)"`
4. **Test Import**: `python -c "from transformers import *"`

## Current Build Artifacts

- **Wheel**: `dist/transformers-4.48.0.dev0-py3-none-any.whl` (9.7 MB)
- **Source**: `dist/transformers-4.48.0.dev0.tar.gz` (8.3 MB)

## Troubleshooting

### Common Issues

1. **"Package already exists"**
   - Version already published on PyPI
   - Solution: Increment version number

2. **"Invalid credentials"**
   - Check API token is correct
   - Ensure token has upload permissions

3. **"Package validation failed"**
   - Run `python3 -m twine check dist/*` to see specific errors
   - Fix issues and rebuild

4. **"Network error"**
   - Check internet connection
   - Verify PyPI is accessible

## Security Considerations

1. **API Tokens**: Never commit API tokens to version control
2. **Credentials**: Use environment variables or keyring for credentials
3. **2FA**: Enable two-factor authentication on PyPI account
4. **Scoped Tokens**: Use project-scoped tokens when possible

## Rollback Procedure

If a bad version is deployed:

1. **Immediate**: PyPI doesn't allow deletion, but you can:
   - Release a new version with fixes
   - Mark the version as deprecated/yanked

2. **Yank a Release**:
   ```bash
   python3 -m twine upload --skip-existing --skip-duplicate dist/*
   # Then use PyPI web interface to yank the bad version
   ```

## Additional Resources

- [PyPI Documentation](https://packaging.python.org/en/latest/guides/distributing-packages-using-setuptools/)
- [Twine Documentation](https://twine.readthedocs.io/)
- [TestPyPI](https://test.pypi.org/)
- [PyPI](https://pypi.org/)

## Support

For issues or questions:
- GitHub Issues: https://github.com/huggingface/transformers/issues
- HuggingFace Forum: https://discuss.huggingface.co/

---

**Last Updated**: December 4, 2024  
**Package Version**: 4.48.0.dev0  
**Status**: Ready for TestPyPI deployment
