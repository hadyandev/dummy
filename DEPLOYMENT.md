# Laravel Docker Deployment Guide

## 🚀 Quick Deployment on New Host

### One-Command Deployment

```bash
# Clone repository
git clone <your-repository-url>
cd dummy-izin

# Run setup (handles everything automatically)
chmod +x setup.sh
./setup.sh
```

**That's it!** The setup script automatically:
- ✅ Detects your user ID and group ID
- ✅ Configures permissions 
- ✅ Sets up environment variables
- ✅ Builds and starts containers
- ✅ Runs database migrations
- ✅ Configures Laravel properly

## 🔒 Permission Handling Features

### Automatic Permission Detection
The setup handles permissions across different hosts by:

1. **Auto-detecting UID/GID** of current user
2. **Updating .env file** with correct user permissions
3. **Creating matching user** in containers
4. **Setting proper ownership** of Laravel directories

### Cross-Platform Support
Works seamlessly on:
- ✅ Ubuntu/Debian Linux
- ✅ CentOS/RHEL/Fedora 
- ✅ macOS (with Docker Desktop)
- ✅ Windows WSL2
- ✅ Any Linux distribution with Docker

## 🐳 Container Architecture

```
Host User (UID:1000, GID:1000)
    ↓
Docker Volumes (bind mounts) 
    ↓
Container User (laravel UID:1000, GID:1000)
```

**Key Benefits:**
- No permission conflicts between host and container
- Files created in container are owned by host user
- Can edit files normally with host editors
- No sudo required for file operations

## 🛠️ Manual Permission Fix (if needed)

If you encounter permission issues after deployment:

```bash
# Method 1: Re-run setup script
./setup.sh

# Method 2: Manual fix
sudo chown -R $(id -u):$(id -g) .
chmod -R 775 storage bootstrap/cache

# Method 3: Fix in container
docker-compose exec -u root app chown -R 1000:1000 /var/www/storage
```

## 🔄 Deployment Scenarios

### Scenario 1: New Server Deployment
```bash
# On new server
git clone <repo>
cd dummy-izin
./setup.sh
# ✅ Ready to use!
```

### Scenario 2: Different User ID
```bash
# If host user has different UID (e.g., 1001)
# Setup script automatically handles this:
./setup.sh  # Detects UID:1001, updates containers accordingly
```

### Scenario 3: Multiple Developers
```bash
# Each developer runs:
git pull
./setup.sh  # Adapts to their specific UID/GID
```

### Scenario 4: CI/CD Deployment
```bash
# In CI/CD pipeline
chmod +x setup.sh
./setup.sh
# Run tests
docker-compose exec app php artisan test
```

## 🐛 Troubleshooting Permission Issues

### Common Permission Problems & Solutions

**Problem:** Cannot save files in VS Code/editor
```bash
# Solution
sudo chown -R $(whoami):$(whoami) .
./setup.sh
```

**Problem:** Laravel logs permission denied
```bash
# Solution
docker-compose exec -u root app chmod -R 777 /var/www/storage/logs
```

**Problem:** Cache/session errors
```bash
# Solution  
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
```

**Problem:** Different UID on new host
```bash
# Solution (automatic)
./setup.sh  # Script detects and fixes automatically
```

## 📋 Pre-deployment Checklist

Before deploying on new host:

- [ ] Docker and Docker Compose installed
- [ ] Git installed
- [ ] Port 8080 and 5432 available (or configure different ports)
- [ ] Sufficient disk space (>2GB for images)

## 🔧 Advanced Configuration

### Custom Ports
```bash
# Edit .env before running setup.sh
WEBSERVER_PORT=8081
DB_PORT=5433
```

### Custom User ID
```bash
# Manually set in .env if needed
UID=1001
GID=1001
```

### Production Deployment
```bash
# Use production environment
cp .env.docker .env.production
# Edit production settings
./setup.sh
```

## 📊 Verification Commands

After deployment, verify everything works:

```bash
# Check containers
docker-compose ps

# Check application
curl http://localhost:8080/api/status

# Check database
docker-compose exec app php artisan migrate:status

# Check permissions
ls -la storage/
```

## 🎯 Key Success Factors

1. **Always run `./setup.sh`** - never skip this step
2. **Don't manually change container user settings** - let script handle it
3. **Use the setup script on every new host** - even if you think permissions are fine
4. **Keep the docker/scripts/entrypoint.sh** - it handles runtime permission fixes

---

**🎉 With this setup, you'll never have Docker permission issues again!**