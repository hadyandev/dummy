# Setup Deployment - Simplified

## 🎯 Overview

Setup sudah disederhanakan untuk **tidak memerlukan** sudo atau berurusan dengan UID/GID. Semua berjalan dengan user `www-data` (UID 33) di dalam container.

## 🚀 Quick Start

### ⚠️ IMPORTANT: Fix Permissions First!

**Sebelum menjalankan setup**, fix ownership file di host agar www-data (UID 33) bisa write:

```bash
# WAJIB dijalankan sekali sebelum setup pertama kali
sudo chown -R 33:33 .
```

**Kenapa perlu?** Container run sebagai `www-data` (UID 33), tapi file di host owned by user Anda. Tanpa fix ini, composer install akan gagal.

### Opsi 1: Menggunakan Makefile (Recommended)
```bash
# Auto fix permissions + setup
make setup
```

### Opsi 2: Menggunakan Script
```bash
# Auto fix permissions + setup
./setup.sh
```

### Opsi 3: Manual
```bash
# 1. Fix permissions first
sudo chown -R 33:33 .

# 2. Build image
docker-compose build --no-cache app

# 3. Start containers
docker-compose up -d

# 4. Run migrations
docker-compose exec app php artisan migrate --force
```

## 📋 Apa yang Dilakukan Setup?

1. ✅ **Fix permissions** - Chown ke 33:33 (www-data) di host
2. ✅ **Cek/Create .env** - Copy dari .env.example jika belum ada
3. ✅ **Stop containers lama** - Clean slate
4. ✅ **Build Docker images** - Fresh build dengan www-data user
5. ✅ **Start containers** - Up semua services
6. ✅ **Wait database** - Tunggu PostgreSQL ready (max 60 detik)
7. ✅ **Clear caches** - Bersihkan Laravel caches
8. ✅ **Run migrations** - Setup database schema
9. ✅ **Check APP_KEY** - Generate jika belum ada
10. ✅ **Create storage link** - Symbolic link untuk public storage

## 🛠️ Makefile Commands

### Setup & Management
```bash
make setup          # Initial setup (auto fix permissions + build + start + migrate)
make start          # Start all containers
make stop           # Stop all containers
make restart        # Restart all containers
make build          # Rebuild containers
make clean          # Stop and remove containers + volumes
```

### Permissions & Dependencies
```bash
make fix-permissions # Fix file ownership to www-data (33:33) - requires sudo
make composer-install # Manually install composer dependencies
```

### Development
```bash
make shell          # Access app container bash
make logs           # View container logs
make status         # Show container status
make info           # Show application information
```

### Database
```bash
make migrate        # Run migrations
make migrate-status # Check migration status
make fresh          # Fresh migration with seeding
make db-shell       # Access PostgreSQL shell
make backup-db      # Create database backup
```

### Laravel
```bash
make tinker         # Laravel Tinker
make clear-cache    # Clear all Laravel caches
make test           # Run tests
```

### Artisan
```bash
make artisan CMD="migrate:status"
make artisan CMD="route:list"
make artisan CMD="queue:work"
```

## 🔍 Troubleshooting

### ⚠️ Permission Issues (Most Common)

#### Error: "vendor does not exist and could not be created"
```bash
# Root cause: File ownership mismatch
# Solution:
sudo chown -R 33:33 .
docker-compose restart app

# Or use make:
make fix-permissions
make start
```

#### Error: "Git refuses to use repository"
```bash
# Already auto-fixed in entrypoint, but if still occurs:
docker-compose exec app git config --global --add safe.directory /var/www

# Check if fix is applied:
docker-compose exec app git config --global --get-all safe.directory
```

#### Composer install fails
```bash
# Check if www-data can write:
docker-compose exec app touch /var/www/test.txt && echo "✅ OK" || echo "❌ FAIL"

# If FAIL, fix permissions:
sudo chown -R 33:33 .
docker-compose restart app

# Or manually trigger composer install:
make composer-install
```

### Container tidak bisa start
```bash
# Cek logs
docker-compose logs app

# Cek semua container
docker-compose ps

# Rebuild if needed
docker-compose down
docker-compose build --no-cache app
docker-compose up -d
```

### Database connection error
```bash
# Verify DB_PORT in .env (should be 5432 for container-to-container)
grep "^DB_" .env

# Test connection
docker-compose exec app php artisan migrate:status

# Check database logs
docker-compose logs db
```

## 📝 Perbedaan dengan Setup Lama

| Aspek | Setup Lama | Setup Baru |
|-------|-----------|------------|
| **User** | Custom UID/GID | www-data (UID 33) |
| **Permission Setup** | Manual chown after errors | ✅ Auto chown before build |
| **Ownership** | Often mismatch | ✅ Consistent (33:33) |
| **Portability** | Server-specific | ✅ Universal |
| **Complexity** | High (sudo, UID/GID detection) | ✅ Low (one chown command) |
| **Git Issues** | Manual fix required | ✅ Auto-fixed in Dockerfile & entrypoint |
| **Composer Install** | Often fails | ✅ Reliable (after permission fix) |

## 🎯 Deployment ke Server Baru

```bash
# 1. Clone/copy project
cd /path/to/project

# 2. Setup .env
cp .env.example .env
nano .env  # Edit sesuai kebutuhan (DB credentials, APP_URL, dll)

# 3. Fix permissions (CRITICAL!)
sudo chown -R 33:33 .

# 4. Run setup
make setup

# 5. Done!
```

### Penjelasan Kenapa Perlu chown ke 33:33:
- Container run sebagai user `www-data` (UID 33, GID 33)
- File di host biasanya owned by user Anda (UID 1000)
- Volume mount `/your/path:/var/www` membuat file accessible di container
- Tapi ownership tetap 1000:1000 (user host Anda)
- www-data (UID 33) tidak bisa write ke file yang owned 1000:1000
- Solusi: Ubah ownership di host ke 33:33 agar match dengan www-data

### Jika Tidak Punya Sudo Access:
```bash
# Minta admin server untuk:
sudo chown -R 33:33 /path/to/project

# Atau setup ACL (alternative):
sudo setfacl -R -m u:33:rwx /path/to/project
sudo setfacl -R -d -m u:33:rwx /path/to/project
```

## 🌐 Accessing Application

Setelah setup selesai:

- **Web**: http://localhost:8090 (atau WEBSERVER_PORT dari .env)
- **Database**: localhost:5433 (atau DB_PORT_EXTERNAL dari .env)

## 📚 File Reference

- `Makefile` - Simplified commands
- `setup.sh` - Simplified setup script (no sudo, no UID/GID)
- `Dockerfile` - Uses www-data user, includes git fix
- `docker/scripts/entrypoint.sh` - Auto composer install, git fix
- `docker-compose.yml` - Clean config (no UID/GID env vars)

## ✅ Benefits

1. ✅ **One command setup** - `make setup` dan selesai
2. ✅ **Consistent permissions** - Ownership jelas (33:33)
3. ✅ **Portable** - Bisa dijalankan di server manapun
4. ✅ **Predictable** - Behavior sama di semua environment
5. ✅ **Automated** - Composer install otomatis saat container start
6. ✅ **Secure** - Running as non-root user (www-data)

## � Best Practices

### Development Environment
```bash
# Fix ownership sekali di awal
sudo chown -R 33:33 .

# Setelah itu, development normal:
make start
make logs
make shell
docker-compose exec app php artisan tinker
```

### Production/Server Deployment
```bash
# 1. Deploy code
git pull origin main

# 2. Fix permissions (if needed)
sudo chown -R 33:33 .

# 3. Rebuild & restart
docker-compose down
docker-compose build --no-cache app
docker-compose up -d

# 4. Run migrations
docker-compose exec app php artisan migrate --force

# 5. Clear caches
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
```

### Verifying Setup is Correct
```bash
# 1. Check ownership on host
ls -la | head -5
# Should show: drwxr-xr-x ... 33 33 ... (good!)
# NOT: drwxr-xr-x ... 1000 1000 ... (need chown!)

# 2. Check if www-data can write
docker-compose exec app touch /var/www/test.txt && echo "✅ Can write" || echo "❌ Cannot write"

# 3. Check composer
docker-compose exec app composer -V

# 4. Check Laravel
docker-compose exec app php artisan -V

# 5. Check app is running
curl http://localhost:8090
```

## �🔄 Migration Guide

Jika upgrade dari setup lama:

```bash
# 1. Backup
make backup-db

# 2. Clean old setup
make clean

# 3. Remove UID/GID dari .env (sudah tidak dipakai)
sed -i '/^UID=/d' .env
sed -i '/^GID=/d' .env

# 4. Fix permissions
sudo chown -R 33:33 .

# 5. Run new setup
make setup
```

## 📚 Additional Resources

- **Permission Fix Details**: Lihat section "Troubleshooting → Permission Issues" di atas
- **Makefile Commands**: Run `make help` untuk list semua commands
- **Docker Logs**: `make logs` atau `docker-compose logs -f app`
- **Laravel Logs**: `docker-compose exec app tail -f storage/logs/laravel.log`

Done! 🎉
