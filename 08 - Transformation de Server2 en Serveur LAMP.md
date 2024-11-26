## **Étape 8 : Transformation de Server2 en Serveur LAMP**

### **Installer Apache, MariaDB et PHP**

1. **Installer les paquets nécessaires** :

   ```bash
   sudo apt install apache2 mariadb-server php libapache2-mod-php php-mysql
   ```

2. **Vérifier l'état des services** :

   ```bash
   sudo systemctl status apache2
   sudo systemctl status mariadb
   ```

3. **Sécuriser MariaDB** :

   ```bash
   sudo mysql_secure_installation
   ```

   - Définissez un mot de passe root pour MariaDB.
   - Supprimez les utilisateurs anonymes.
   - Désactivez l'accès root à distance.

### **Comprendre les Services sous Linux et la Gestion des Permissions**

- **Services** : Gérés par **systemd**.
- **Commandes utiles** :

  ```bash
  sudo systemctl start|stop|restart|reload|status nom_du_service
  ```

- **Permissions** :

  - Les fichiers web doivent appartenir à l'utilisateur `www-data` pour qu'Apache puisse y accéder.
  - Attribuez les permissions avec :

    ```bash
    sudo chown -R www-data:www-data /var/www/nom_du_site
    ```

---
