# Dummy Izin - Laravel Docker Environment

Laravel application with Docker Compose setup including PostgreSQL, Nginx, Queue Workers, and Scheduler.

---

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose installed
- Git

### Setup

```bash
# Clone repository
git clone <repository-url>
cd dummy-izin

# Copy environment file
cp .env.example .env

# Setup and start containers
make setup
```


---

## 📋 Available Commands

### Common Operations
```bash
make setup          # Initial setup (build, start, migrate)
make start          # Start all containers
make stop           # Stop all containers
make restart        # Restart containers
make ps             # Show container status
make info           # Show environment info
```

### Logs
```bash
make logs           # View all container logs
make logs-app       # App container only
make logs-queue     # Queue worker only
make logs-db        # Database only
make logs-web       # Nginx webserver only
make logs-scheduler # Scheduler only
```

### Development
```bash
make shell          # Access app container bash
make tinker         # Laravel Tinker
make test           # Run tests
make migrate        # Run migrations
make cache-clear    # Clear all caches
```

### Laravel Artisan & Composer
```bash
make artisan CMD="migrate:status"
make artisan CMD="make:controller UserController"
make composer CMD="require package/name"
```

### Database
```bash
make db-shell       # Access PostgreSQL shell
make migrate-fresh  # Fresh migration with seed
```

### Cleanup
```bash
make clean          # Remove containers and volumes
```

---

## 🏗️ Architecture

### Docker Volumes Strategy
Uses **Docker named volumes** for dependency isolation:
- ✅ `vendor/` - Composer dependencies (in Docker volume)
- ✅ `storage/` - Laravel storage (in Docker volume)
- ✅ `bootstrap/cache/` - Bootstrap cache (in Docker volume)
- ✅ Source code - Bind mounted from host (editable)

**Benefits:**
- No permission issues (no sudo required)
- Fast composer install
- Clean Git repository
- Easy development workflow

### Services
- **app** - PHP 8.2-FPM application container
- **webserver** - Nginx web server
- **db** - PostgreSQL 16 database
- **queue** - Laravel queue worker
- **scheduler** - Laravel task scheduler

---

## 🔧 Configuration

### Environment Variables

Key variables in `.env`:

```bash
# Application
APP_URL=http://localhost:8090
APP_ENV=local
APP_DEBUG=true

# Docker Ports
WEBSERVER_PORT=8090      # Host port for web access
DB_PORT_EXTERNAL=5433    # Host port for database

# Database (container network)
DB_HOST=db               # Use container name
DB_PORT=5432             # Internal container port
DB_DATABASE=dummy
DB_USERNAME=dummy
DB_PASSWORD=dummy

# OSSHUB Integration
OSSHUB_ENDPOINT=http://localhost:9000/api/v1/
OSSHUB_USERNAME=your_username
OSSHUB_PASSWORD=your_password
```

### DNS Configuration

If you encounter DNS resolution issues from containers, the setup includes custom DNS configuration:

```yaml
# docker-compose.yml
services:
  app:
    dns:
      - 172.30.100.125  # Custom DNS (if needed)
      - 8.8.8.8         # Google DNS fallback
```

---

## 📝 Notes

- **No sudo required** - Docker volumes handle permissions automatically
- **Service discovery** - Use container names (`db`, `redis`) in configs  
- **Custom DNS** - Configured for external API access
- **Auto-restart** - Containers restart automatically unless stopped
- **View detailed info** - Run `make info` to see current configuration
