# Script de instalación de Moodle y Prestashop

Este script automatiza la instalación de **Moodle** y **Prestashop** en un servidor Ubuntu. Configura el entorno necesario, instala Apache, PHP con los módulos requeridos, y configura MySQL para ambas aplicaciones.

## Requisitos previos

Antes de ejecutar el script, asegúrate de cumplir con los siguientes requisitos:

1. **Sistema operativo**: Ubuntu (versión recomendada: 20.04 o superior).
2. **Acceso de superusuario**: El script requiere permisos de `sudo`.
3. **Variables de entorno**: Crea un archivo `.env.local` en el mismo directorio que el script con las siguientes variables:

    ```env
    ROOT_PASSWORD=tu_contraseña_actual_de_root_mysql
    MYSQL_ROOT_PASSWORD=nueva_contraseña_de_root_mysql
    MOODLE_DB_USER=nombre_usuario_moodle
    MOODLE_DB_PASS=contraseña_usuario_moodle
    ```

4. **Herramientas necesarias**: Instala `wget` y `unzip` si no están disponibles en tu sistema:
    ```bash
    sudo apt install wget unzip -y
    ```

## Uso

1. **Clona el repositorio o descarga el script**.
2. Asegúrate de que el script tiene permisos de ejecución:
    ```bash
    chmod +x install.sh
    ```
3. Ejecuta el script con privilegios de superusuario:
    ```bash
    sudo ./install.sh
    ```

## Funcionalidades del script

- **Actualización del sistema**: Realiza una actualización de paquetes.
- **Instalación de Apache y PHP**: Configura el servidor web y los módulos necesarios.
- **Configuración de MySQL**:
    - Cambia la contraseña de root.
    - Crea una base de datos y un usuario para Moodle.
- **Instalación de Moodle**:
    - Descarga la última versión estable.
    - Configura los permisos y el archivo `config.php`.
- **Instalación de Prestashop**:
    - Descarga la última versión estable.
    - Instala los módulos adicionales necesarios.
    - Configura el servidor Apache.
- **Limpieza**: Elimina archivos temporales utilizados durante la instalación.

## Acceso a las aplicaciones

Una vez completada la instalación, puedes acceder a las aplicaciones desde tu navegador usando la IP del servidor.

- **Moodle**: [http://192.168.1.38/moodle](http://192.168.1.38/moodle)
- **Prestashop**: [http://192.168.1.38/prestashop](http://192.168.1.38/prestashop)

> Reemplaza `192.168.1.38` con la IP o dominio de tu servidor si es diferente.

## Solución de problemas

- Si Moodle o Prestashop no cargan, verifica el estado del servidor Apache:
    ```bash
    sudo systemctl status apache2
    ```
- Comprueba los registros de errores de Apache:
    ```bash
    sudo tail -f /var/log/apache2/error.log
    ```
- Asegúrate de que las dependencias de PHP estén instaladas correctamente.

## Licencia

Este script se distribuye bajo la licencia MIT. Puedes usarlo y modificarlo libremente.
