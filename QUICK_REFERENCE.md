# Quick Reference

## 🚨 Most Important First!

### Before First Setup
```bash
# MUST DO: Fix permissions for www-data user
sudo chown -R 33:33 .
```

## 🚀 Common Commands

### Setup & Start
```bash
make setup              # First time setup (auto fix permissions)
make start              # Start containers
make stop               # Stop containers
make restart            # Restart containers
```

### Troubleshooting
```bash
make logs               # View application logs
make status             # Check container status
make fix-permissions    # Fix ownership issues
make composer-install   # Manually install dependencies
```

### Development
```bash
make shell              # Enter container bash
make tinker             # Laravel Tinker
make migrate            # Run migrations
make fresh              # Fresh migration + seed
```

### Artisan Commands
```bash
make artisan CMD="route:list"
make artisan CMD="queue:work"
make artisan CMD="migrate:status"
```

## ❌ Common Errors & Fixes

### Error: "vendor does not exist and could not be created"
```bash
sudo chown -R 33:33 .
docker-compose restart app
```

### Error: "Git refuses to use repository"
Already auto-fixed, but if still occurs:
```bash
docker-compose exec app git config --global --add safe.directory /var/www
```

### Error: "Permission denied" for storage/logs
```bash
make fix-permissions
```

## 📋 Checklist for New Server

- [ ] Clone/copy project
- [ ] Create/edit .env file
- [ ] Run: `sudo chown -R 33:33 .`
- [ ] Run: `make setup`
- [ ] Access: http://localhost:8090
- [ ] Verify: `make status`

## 📚 Documentation

- **Full Setup Guide**: See `SETUP_GUIDE.md`
- **Docker User Info**: See `DOCKER_USER_PERMISSIONS.md`
- **Network Setup**: See `DOCKER_NETWORK_SETUP.md`
- **All Commands**: Run `make help`

## 🆘 Emergency Fixes

### Cannot access application
```bash
docker-compose logs app
docker-compose ps
curl http://localhost:8090
```

### Database connection fails
```bash
# Check .env DB_PORT should be 5432 (not 5433)
grep "^DB_" .env
docker-compose logs db
```

### Composer install keeps failing
```bash
# 1. Stop everything
docker-compose down

# 2. Fix permissions
sudo chown -R 33:33 .

# 3. Remove vendor if exists
rm -rf vendor

# 4. Fresh start
docker-compose build --no-cache app
docker-compose up -d
```

## 💡 Tips

- **Always fix permissions first** before setup
- **Use make commands** for consistency  
- **Check logs** when errors occur: `make logs`
- **UID 33 = www-data**, standard di Debian/Ubuntu
- **Permission fixes only needed ONCE** at first setup
