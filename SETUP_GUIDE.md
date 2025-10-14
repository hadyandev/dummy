# Setup Deployment - Simplified

## 🎯 Overview

Setup sudah disederhanakan untuk **tidak memerlukan** sudo atau berurusan dengan UID/GID. Semua berjalan dengan user `www-data` (UID 33) di dalam container.

## 🚀 Quick Start

### Opsi 1: Menggunakan Makefile (Recommended)
```bash
make setup
```

### Opsi 2: Menggunakan Script
```bash
./setup.sh
```

### Opsi 3: Manual
```bash
# Build image
docker-compose build --no-cache app

# Start containers
docker-compose up -d

# Run migrations
docker-compose exec app php artisan migrate --force
```

## 📋 Apa yang Dilakukan Setup?

1. ✅ **Cek/Create .env** - Copy dari .env.example jika belum ada
2. ✅ **Stop containers lama** - Clean slate
3. ✅ **Build Docker images** - Fresh build dengan www-data user
4. ✅ **Start containers** - Up semua services
5. ✅ **Wait database** - Tunggu PostgreSQL ready (max 60 detik)
6. ✅ **Clear caches** - Bersihkan Laravel caches
7. ✅ **Run migrations** - Setup database schema
8. ✅ **Check APP_KEY** - Generate jika belum ada
9. ✅ **Create storage link** - Symbolic link untuk public storage

## 🛠️ Makefile Commands

### Setup & Management
```bash
make setup          # Initial setup (build + start + migrate)
make start          # Start all containers
make stop           # Stop all containers
make restart        # Restart all containers
make build          # Rebuild containers
make clean          # Stop and remove containers + volumes
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

### Container tidak bisa start
```bash
# Cek logs
docker-compose logs app

# Cek semua container
docker-compose ps
```

### Git ownership error (sudah diperbaiki di image)
Sudah ditangani di:
- Dockerfile: `git config --global --add safe.directory '*'`
- Entrypoint: `git config --global --add safe.directory /var/www`

### Database connection error
```bash
# Cek apakah DB_PORT di .env = 5432 (bukan 5433)
grep "^DB_" .env

# Test koneksi dari container
docker-compose exec app php artisan migrate:status
```

### Permission issues
Tidak perlu lagi fix permissions manual! Container menggunakan `www-data` user yang sudah memiliki permissions yang benar.

## 📝 Perbedaan dengan Setup Lama

| Aspek | Setup Lama | Setup Baru |
|-------|-----------|------------|
| **User** | Custom UID/GID | www-data (UID 33) |
| **Sudo** | Required | ❌ Not needed |
| **Ownership** | Manual chown | ✅ Automatic |
| **Portability** | Server-specific | ✅ Universal |
| **Complexity** | High | ✅ Low |
| **Git Issues** | Manual fix | ✅ Auto-fixed |

## 🎯 Deployment ke Server Baru

```bash
# 1. Clone/copy project
cd /path/to/project

# 2. Setup .env
cp .env.example .env
nano .env  # Edit sesuai kebutuhan

# 3. Run setup
make setup

# 4. Done!
```

**Tidak perlu:**
- ❌ Set UID/GID di .env
- ❌ Run dengan sudo
- ❌ Manual chown/chmod
- ❌ Fix git ownership

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
2. ✅ **No sudo required** - Tidak perlu root access
3. ✅ **Portable** - Bisa dijalankan di server manapun
4. ✅ **Consistent** - Behavior sama di semua environment
5. ✅ **Automated** - Composer install otomatis saat container start
6. ✅ **Secure** - Running as non-root user (www-data)

## 🔄 Migration Guide

Jika upgrade dari setup lama:

```bash
# 1. Backup
make backup-db

# 2. Clean old setup
make clean

# 3. Remove UID/GID dari .env (sudah tidak dipakai)
sed -i '/^UID=/d' .env
sed -i '/^GID=/d' .env

# 4. Run new setup
make setup
```

Done! 🎉
