#!/bin/bash

# Script to fix file ownership issues
# This script should be run when files are created with wrong ownership (root instead of user)

echo "🔧 Fixing file ownership and permissions..."

# Get current user info
CURRENT_USER=$(whoami)
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "👤 Current user: $CURRENT_USER (UID: $CURRENT_UID, GID: $CURRENT_GID)"

# Fix ownership of all files in project
echo "📁 Fixing project file ownership..."
sudo chown -R $CURRENT_UID:$CURRENT_GID .

# Set proper permissions for directories and files
echo "🔐 Setting proper permissions..."
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

# Make scripts executable
chmod +x *.sh
chmod +x setup.sh 2>/dev/null || true
chmod +x docker/scripts/*.sh 2>/dev/null || true

echo "✅ File ownership and permissions fixed!"
echo ""
echo "💡 To prevent this issue in the future:"
echo "   - Use 'make artisan' instead of docker commands directly"
echo "   - Run 'make fix-permissions' if you encounter permission issues"
echo "   - Avoid using sudo with docker commands"