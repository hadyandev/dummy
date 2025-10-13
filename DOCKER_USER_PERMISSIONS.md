# Docker User Permissions - Simplified Setup

## Overview
Aplikasi ini menggunakan user `www-data` bawaan dari image PHP-FPM, sehingga tidak perlu berurusan dengan UID/GID atau membuat user custom.

## Keuntungan Pendekatan Ini

✅ **Fleksibel**: Bisa dijalankan di server manapun tanpa perlu konfigurasi UID/GID
✅ **Sederhana**: Tidak ada konflik dengan user root atau permission issues
✅ **Portabel**: Image bisa digunakan di berbagai environment tanpa rebuild
✅ **Best Practice**: Menggunakan non-root user (www-data) untuk security

## Cara Kerja

1. **Build Stage**: 
   - Install dependencies sebagai `www-data` user
   - Semua file di `/var/www` owned by `www-data:www-data`

2. **Runtime**:
   - Container berjalan sebagai `www-data` user
   - Tidak perlu switch user atau permission workarounds

3. **File Permissions**:
   - Storage dan cache directories: `775` (group writable)
   - Owned by `www-data:www-data`

## Jika Ada Permission Issues di Host

Jika Anda perlu edit file di host dan ada permission issues:

```bash
# Cek UID/GID dari www-data di container
docker-compose exec app id

# Output biasanya: uid=33(www-data) gid=33(www-data)

# Set ownership di host (optional, hanya jika diperlukan)
sudo chown -R 33:33 storage bootstrap/cache
```

## File Permissions di Container

```
/var/www/
├── storage/          → 775 (www-data:www-data)
├── bootstrap/cache/  → 775 (www-data:www-data)
└── *                 → 755 (www-data:www-data)
```

## Troubleshooting

### Permission Denied saat menulis file

```bash
# Masuk ke container dan cek permissions
docker-compose exec app ls -la storage/

# Fix permissions (jika diperlukan)
docker-compose exec app chmod -R 775 storage bootstrap/cache
```

### File tidak bisa diedit di host

Ini normal karena file owned by `www-data` (UID 33). Ada 2 solusi:

**Option 1: Edit via container**
```bash
docker-compose exec app bash
nano /var/www/yourfile.php
```

**Option 2: Temporary fix di host**
```bash
sudo chown -R $USER:$USER .
# Edit files
# Kemudian kembalikan ke www-data
sudo chown -R 33:33 .
```

**Option 3: Add user ke group www-data di host** (paling praktis)
```bash
# Cek apakah group 33 ada di host
getent group 33

# Jika tidak ada, buat group
sudo groupadd -g 33 www-data

# Add user Anda ke group
sudo usermod -aG www-data $USER

# Re-login atau jalankan
newgrp www-data

# Set group permissions
sudo chgrp -R www-data .
sudo chmod -R g+w storage bootstrap/cache
```

## Migrasi dari Setup Lama (dengan UID/GID)

Jika sebelumnya menggunakan UID/GID custom:

1. ✅ Hapus `UID` dan `GID` dari `.env`
2. ✅ Rebuild image: `docker-compose build --no-cache`
3. ✅ Restart containers: `docker-compose up -d`
4. ✅ Fix permissions (jika perlu): `docker-compose exec app chmod -R 775 storage bootstrap/cache`

## Notes

- User `www-data` memiliki UID=33 dan GID=33 di hampir semua distribusi Linux
- Ini adalah user standard untuk web servers (nginx, apache, php-fpm)
- Tidak perlu custom entrypoint script untuk manage permissions
