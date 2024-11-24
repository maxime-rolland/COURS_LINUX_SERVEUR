## **Étape 9 : Installation de Services Web**

### **Installer GLPI pour `glpi.learn-it.local`**

1. **Télécharger GLPI** :

   ```bash
   cd /tmp
   wget https://github.com/glpi-project/glpi/releases/download/10.0.7/glpi-10.0.7.tgz
   tar -xzvf glpi-10.0.7.tgz
   ```

2. **Installer GLPI** :

   - Déplacez les fichiers :

     ```bash
     sudo mv glpi /var/www/
     ```

   - Renommez le répertoire :

     ```bash
     sudo mv /var/www/glpi /var/www/glpi.learn-it.local
     ```

   - Attribuez les permissions :

     ```bash
     sudo chown -R www-data:www-data /var/www/glpi.learn-it.local
     ```

3. **Configurer le VirtualHost pour GLPI**

   - Créez le fichier de configuration :

     ```bash
     sudo nano /etc/apache2/sites-available/glpi.learn-it.local.conf
     ```

   - Contenu du fichier (selon la documentation officielle) :

     ```apache
     <VirtualHost *:80>
         ServerName glpi.learn-it.local

         DocumentRoot /var/www/glpi.learn-it.local/public

         <Directory /var/www/glpi.learn-it.local/public>
             Require all granted

             RewriteEngine On

             # Ensure authorization headers are passed to PHP.
             RewriteCond %{HTTP:Authorization} ^(.+)$
             RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

             # Redirect all requests to GLPI router, unless file exists.
             RewriteCond %{REQUEST_FILENAME} !-f
             RewriteRule ^(.*)$ index.php [QSA,L]
         </Directory>
     </VirtualHost>
     ```

   **Explication** :

   - Le `DocumentRoot` pointe vers le répertoire `/public` comme recommandé.
   - Les directives `RewriteEngine`, `RewriteCond`, et `RewriteRule` assurent que toutes les requêtes sont correctement redirigées vers le routeur de GLPI, sauf si le fichier demandé existe.

4. **Activer le site et les modules nécessaires** :

   ```bash
   sudo a2enmod rewrite
   sudo a2ensite glpi.learn-it.local.conf
   sudo systemctl reload apache2
   ```

5. **Créer la base de données pour GLPI** :

   ```bash
   sudo mysql -u root -p
   ```

   Dans le shell MariaDB :

   ```sql
   CREATE DATABASE glpi_db;
   CREATE USER 'glpi_user'@'localhost' IDENTIFIED BY 'password_glpi';
   GRANT ALL PRIVILEGES ON glpi_db.* TO 'glpi_user'@'localhost';
   FLUSH PRIVILEGES;
   EXIT;
   ```

6. **Finaliser l'installation de GLPI** :

   - Accédez à `http://glpi.learn-it.local` depuis le client Windows.
   - Suivez les instructions d'installation.

7. **Configurer les Entrées DNS**

   - Assurez-vous que l'enregistrement DNS pour `glpi` pointe vers `192.168.200.2` dans le fichier de zone directe `/var/lib/bind/zones/db.learn-it.local`.

   - Incrémentez le numéro de série du SOA et redémarrez Bind9 :

     ```bash
     sudo systemctl restart bind9
     ```

---
