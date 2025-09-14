#!/bin/bash
# Cloud-init script for MySQL database setup
# This script will be executed on instance launch

# Log everything
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Update the system
yum update -y

# Prevent bash from interpreting "!" (history expansion)
set +H

# Install MySQL Server 8.0 for Amazon Linux 2023
# Use the Amazon Linux 2023 repository instead of CentOS 7
yum install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
yum install -y mysql-community-server --nogpgcheck

# Start and enable MySQL
systemctl start mysqld
systemctl enable mysqld

# Get the temporary root password
TEMP_ROOT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

# Set permanent root password
ROOT_PASSWORD="${root_password}"
mysql -u root -p"$TEMP_ROOT_PASSWORD" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASSWORD';"

# Create database and users
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"
DB_ADMIN_USER="${db_admin_user}"
DB_ADMIN_PASSWORD="${db_admin_password}"

# Create database
mysql -u root -p"$ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

# Create admin user with full privileges (can modify database structure)
mysql -u root -p"$ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$DB_ADMIN_USER'@'%' IDENTIFIED BY '$DB_ADMIN_PASSWORD';"
mysql -u root -p"$ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_ADMIN_USER'@'%';"

# Create environment user with limited privileges (data manipulation only)
mysql -u root -p"$ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"
mysql -u root -p"$ROOT_PASSWORD" -e "GRANT SELECT, INSERT, UPDATE, DELETE ON $DB_NAME.* TO '$DB_USER'@'%';"

mysql -u root -p"$ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

# Configure MySQL to accept external connections
echo "bind-address = 0.0.0.0" >> /etc/my.cnf
systemctl restart mysqld

echo "MySQL setup completed successfully"
echo "Database: $DB_NAME"
echo "Environment User: $DB_USER (DML privileges only)"
echo "Admin User: $DB_ADMIN_USER (full privileges)"
echo "Host: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
