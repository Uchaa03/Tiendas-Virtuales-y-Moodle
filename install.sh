#!/bin/bash
# La utilización de barras invertidas es para mejorar la legibilidad del script

# Importación de variables de entorno recordatorio de que se tiene que generar el propio
source .env.local

# Actualización de paquetes del sistema
sudo apt update && \
sudo apt upgrade -y && \
echo "" && \
echo "Sistema actualizado correctamente"
sleep 2  # Espera 2 segundos para que dé tiempo a leer los mensajes

# Instalación de Apache
sudo apt install apache2 -y && \
echo "" && \
echo "Apache fue instalado correctamente"
sleep 2

# Cambiar la contraseña de root de MySQL utilizando nuestras variables de entorno
mysql -u root -p"$ROOT_PASSWORD" <<EOF
  ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY "$MYSQL_ROOT_PASSWORD";
  FLUSH PRIVILEGES;
EOF

echo "" && \
echo "La contraseña de root de MySQL fue cambiada con éxito"
sleep 3

# Instalación de PHP y sus módulos
sudo apt install php libapache2-mod-php php-mysql php-xml php-intl php-zip php-curl -y && \
echo "" && echo "PHP se instaló exitosamente"
sudo cp ../php/info.php /var/www/html/info.php
sudo chown www-data:www-data /var/www/html/info.php && echo "" && echo "Fichero copiado"
sudo systemctl restart apache2 && echo "" && echo "Módulos cargados"

# Configuración de MySQL para Moodle
echo "" && echo "Configurando base de datos para Moodle..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
  CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  CREATE USER '$MOODLE_DB_USER'@'localhost' IDENTIFIED BY '$MOODLE_DB_PASS';
  GRANT ALL PRIVILEGES ON moodle.* TO '$MOODLE_DB_USER'@'localhost';
  FLUSH PRIVILEGES;
EOF
echo "Base de datos para Moodle configurada correctamente."
sleep 3

# Crear el directorio moodledata y asignar permisos
echo "" && echo "Creando directorio moodledata..."
sudo mkdir -p /var/moodledata
sudo chmod -R 0777 /var/moodledata
sudo chown -R www-data:www-data /var/moodledata
echo "Directorio moodledata creado correctamente."
sleep 2

# Instalación de Moodle
echo "" && echo "Instalando Moodle..."
MOODLE_URL="https://download.moodle.org/download.php/direct/stable402/moodle-latest-402.tgz"
sudo wget -O moodle.tgz "$MOODLE_URL"
sudo tar -xvzf moodle.tgz -C /var/www/html/
sudo chown -R www-data:www-data /var/www/html/moodle

# Configurar config.php automáticamente
sudo cp /var/www/html/moodle/config-dist.php /var/www/html/moodle/config.php
sudo sed -i "s|\$CFG->dataroot.*|\\\$CFG->dataroot = '/var/moodledata';|" /var/www/html/moodle/config.php
sudo sed -i "s|'dbtype' => '.*'|'dbtype' => 'mysqli'|" /var/www/html/moodle/config.php
sudo sed -i "s|'dbname' => '.*'|'dbname' => 'moodle'|" /var/www/html/moodle/config.php
sudo sed -i "s|'dbuser' => '.*'|'dbuser' => '$MOODLE_DB_USER'|" /var/www/html/moodle/config.php
sudo sed -i "s|'dbpass' => '.*'|'dbpass' => '$MOODLE_DB_PASS'|" /var/www/html/moodle/config.php
echo "Moodle instalado y configurado correctamente."
sleep 3

# Instalación de Prestashop
echo "" && echo "Instalando Prestashop..."
PRESTASHOP_URL="https://download.prestashop.com/download/releases/prestashop_1.7.8.8.zip"
sudo wget -O prestashop.zip "$PRESTASHOP_URL"
sudo apt install php-soap php-mbstring php-gd php-bcmath -y
sudo unzip prestashop.zip -d /var/www/html/prestashop
sudo chown -R www-data:www-data /var/www/html/prestashop
sudo a2enmod rewrite
sudo systemctl restart apache2
echo "Prestashop instalado correctamente."
sleep 3

# Limpieza de archivos temporales
echo "Limpiando archivos temporales..."
rm moodle.tgz prestashop.zip
echo "Archivos temporales eliminados."

echo "" && echo "Instalación completada"
