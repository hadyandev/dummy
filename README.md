# Laravel Docker Environment

A complete Laravel development environment using Docker with PostgreSQL, Nginx, Queue Workers, and Task Scheduler.

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose installed
- Git
- Sudo access (for fixing permissions)

### One-Command Setup

```bash
git clone <repository-url>
cd dummy-izin

# IMPORTANT: Fix permissions first!
sudo chown -R 33:33 .

# Run setup
make setup
```

**That's it!** Application will be available at http://localhost:8090

### Why chown to 33:33?

Container runs as `www-data` user (UID 33). Volume mount makes your host files accessible in container, but ownership stays as your user (UID 1000). www-data cannot write to files owned by 1000, so we change ownership to 33:33 on host.

### Alternative Setup Methods

**Option 1: Using setup script**
```bash
./setup.sh  # Auto fix permissions + setup
```

**Option 2: Using Makefile**
```bash
make setup  # Auto fix permissions + setup
```

**Option 3: Manual (if no sudo)**
```bash
# Ask server admin to run:
sudo chown -R 33:33 /path/to/project

# Then you can:
docker-compose build --no-cache app
docker-compose up -d
docker-compose exec app php artisan migrate --force
```
   docker-compose exec app php artisan migrate
   docker-compose exec app php artisan key:generate
   ```

## 📊 Services

| Service | Description | URL/Port |
|---------|-------------|----------|
| **Laravel App** | Main Laravel application | http://localhost:8080 |
| **PostgreSQL** | Database server | localhost:3306 (mapped from 5432) |
| **Queue Worker** | Background job processor | - |
| **Scheduler** | Cron job scheduler | - |
| **Nginx** | Web server | http://localhost:8080 |

## 🔧 Configuration

### Environment Variables

Key configuration options in `.env`:

```env
# Application
APP_URL=http://localhost:8080

# Docker Ports
WEBSERVER_PORT=8080
DB_PORT=5432

# Database (PostgreSQL)
DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=laravel

# User Permissions (Auto-detected by setup.sh)
UID=1000
GID=1000
```

### Port Configuration

- **Web**: `WEBSERVER_PORT` (default: 8080)
- **Database**: `DB_PORT` (default: 5432, mapped to 3306 for compatibility)

## 🗄️ Database Access

Connect to PostgreSQL using any database client:

```
Host: localhost
Port: 3306 (mapped port)  
Database: laravel
Username: laravel
Password: laravel
Driver: PostgreSQL
```

## 🛠️ Development Commands

### Container Management
```bash
# Start containers
docker-compose up -d

# Stop containers
docker-compose down

# View logs
docker-compose logs -f

# Restart specific service
docker-compose restart app
```

### Laravel Commands
```bash
# Access container shell
docker-compose exec app bash

# Run artisan commands
docker-compose exec app php artisan migrate
docker-compose exec app php artisan make:controller UserController

# Clear caches
docker-compose exec app php artisan config:clear
```

## 🔒 Permission Handling

This setup automatically handles permission issues across different hosts:

1. **Automatic Detection**: Setup script detects your UID/GID
2. **Dynamic User Creation**: Container creates user with matching UID/GID  
3. **Proper Ownership**: Files maintain correct ownership between host and container
4. **Cross-Platform**: Works on Linux, macOS, and Windows (WSL)

### Troubleshooting Permissions

If you encounter permission issues:

```bash
# Re-run setup script
./setup.sh

# Or manually fix permissions
sudo chown -R $(id -u):$(id -g) .
chmod -R 775 storage bootstrap/cache
```

## 📱 API Endpoints

### Public Endpoints
- `GET /api/status` - API health check
- `GET /api/health` - Application health check  
- `POST /api/osshub-login` - Login endpoint

### Protected Endpoints (require authentication)
- `GET /api/user` - Get authenticated user

## 🆘 Troubleshooting

### Common Issues

**Permission Denied Errors:**
```bash
# Quick fix for container permissions
make fix-permissions

# Fix host file ownership issues (when files owned by root)
make fix-ownership
# or
./fix-ownership.sh

# Or manual fix for containers
docker-compose exec app chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
docker-compose exec app chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Re-run full setup if needed
./setup.sh
```

**File Ownership Issues (Cannot Save Files):**
```bash
# When VS Code shows "cannot save file" or files owned by root
make fix-ownership

# Or check file ownership
ls -la app/
# If files show 'root root', run:
sudo chown -R $(id -u):$(id -g) .
```

**Laravel View Compilation Issues:**
```bash
# Clear view cache and fix permissions
make clear-cache
make fix-permissions
```

**Database Connection Failed:**
```bash
docker-compose restart db
docker-compose exec app php artisan config:clear
```

**Port Already in Use:**
```bash
# Change ports in .env
WEBSERVER_PORT=8081
DB_PORT=5433
```

---

**Made with ❤️ for Laravel development**

## About Laravel

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects, such as:

- [Simple, fast routing engine](https://laravel.com/docs/routing).
- [Powerful dependency injection container](https://laravel.com/docs/container).
- Multiple back-ends for [session](https://laravel.com/docs/session) and [cache](https://laravel.com/docs/cache) storage.
- Expressive, intuitive [database ORM](https://laravel.com/docs/eloquent).
- Database agnostic [schema migrations](https://laravel.com/docs/migrations).
- [Robust background job processing](https://laravel.com/docs/queues).
- [Real-time event broadcasting](https://laravel.com/docs/broadcasting).

Laravel is accessible, powerful, and provides tools required for large, robust applications.

## Learning Laravel

Laravel has the most extensive and thorough [documentation](https://laravel.com/docs) and video tutorial library of all modern web application frameworks, making it a breeze to get started with the framework.

You may also try the [Laravel Bootcamp](https://bootcamp.laravel.com), where you will be guided through building a modern Laravel application from scratch.

If you don't feel like reading, [Laracasts](https://laracasts.com) can help. Laracasts contains thousands of video tutorials on a range of topics including Laravel, modern PHP, unit testing, and JavaScript. Boost your skills by digging into our comprehensive video library.

## Laravel Sponsors

We would like to extend our thanks to the following sponsors for funding Laravel development. If you are interested in becoming a sponsor, please visit the [Laravel Partners program](https://partners.laravel.com).

### Premium Partners

- **[Vehikl](https://vehikl.com)**
- **[Tighten Co.](https://tighten.co)**
- **[Kirschbaum Development Group](https://kirschbaumdevelopment.com)**
- **[64 Robots](https://64robots.com)**
- **[Curotec](https://www.curotec.com/services/technologies/laravel)**
- **[DevSquad](https://devsquad.com/hire-laravel-developers)**
- **[Redberry](https://redberry.international/laravel-development)**
- **[Active Logic](https://activelogic.com)**

## Contributing

Thank you for considering contributing to the Laravel framework! The contribution guide can be found in the [Laravel documentation](https://laravel.com/docs/contributions).

## Code of Conduct

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
