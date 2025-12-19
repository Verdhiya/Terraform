#!/bin/bash
# ============================================
# Nginx Installation Script
# Waits for cloud-init, installs and starts nginx
# ============================================

set -e  # Exit on any error

# Wait for cloud-init to complete
echo "Waiting for cloud-init to complete..."
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
    sleep 1
done
echo "Cloud-init completed."

# Update package lists
echo "Updating package lists..."
apt-get update -y

# Install nginx
echo "Installing nginx..."
apt-get install -y nginx

# Start nginx service
echo "Starting nginx service..."
systemctl start nginx

# Enable nginx to start on boot
echo "Enabling nginx on boot..."
systemctl enable nginx

# Verify nginx is running
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx installed and running successfully!"
    echo "Access your server at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
else
    echo "❌ Nginx installation failed!"
    exit 1
fi
