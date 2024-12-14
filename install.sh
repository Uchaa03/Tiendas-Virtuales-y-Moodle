#!/bin/bash

# Configuración
MOODLE_VERSION="stable401" # Versión de Moodle
PRESTASHOP_VERSION="8.0.4" # Versión de PrestaShop

# Instalar dependencias comunes
echo "=== Instalando dependencias ==="
sudo apt-get update
sudo apt-get install -y apache2 mysql-server php php-cli php-mysql php-zip php-xml php-mbstring php-curl php-soap php-intl unzip git

# Configurar base de datos para Moodle
echo "=== Configurando base de datos para Moodle ==="
mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY 'moodlepassword';
GRANT ALL PRIVILEGES ON moodle.* TO 'moodleuser'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Instalar Moodle
echo "=== Descargando e instalando Moodle ==="
sudo git clone -b ${MOODLE_VERSION} git://git.moodle.org/moodle.git /var/www/html/moodle
sudo mkdir -p /var/www/moodledata
sudo chown -R www-data:www-data /var/www/html/moodle /var/www/moodledata
sudo chmod -R 755 /var/www/html/moodle /var/www/moodledata

# Configurar Apache para Moodle
echo "=== Configurando Apache para Moodle ==="
sudo tee /etc/apache2/sites-available/moodle.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html/moodle
    <Directory /var/www/html/moodle>
        Options FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/moodle_error.log
    CustomLog \${APACHE_LOG_DIR}/moodle_access.log combined
</VirtualHost>
EOF

sudo a2ensite moodle.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# Configurar base de datos para PrestaShop
echo "=== Configurando base de datos para PrestaShop ==="
mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE prestashop DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'prestashopuser'@'localhost' IDENTIFIED BY 'prestashoppassword';
GRANT ALL PRIVILEGES ON prestashop.* TO 'prestashopuser'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Instalar PrestaShop
echo "=== Descargando e instalando PrestaShop ==="
sudo mkdir -p /var/www/html/prestashop
sudo wget https://download.prestashop.com/download/releases/prestashop_${PRESTASHOP_VERSION}.zip -O /tmp/prestashop.zip
sudo unzip /tmp/prestashop.zip -d /var/www/html/prestashop
sudo rm /tmp/prestashop.zip
sudo chown -R www-data:www-data /var/www/html/prestashop
sudo chmod -R 755 /var/www/html/prestashop

# Configurar Apache para PrestaShop
echo "=== Configurando Apache para PrestaShop ==="
sudo tee /etc/apache2/sites-available/prestashop.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html/prestashop
    <Directory /var/www/html/prestashop>
        Options FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/prestashop_error.log
    CustomLog \${APACHE_LOG_DIR}/prestashop_access.log combined
</VirtualHost>
EOF

sudo a2ensite prestashop.conf
sudo systemctl restart apache2

echo "=== Instalación completa ==="