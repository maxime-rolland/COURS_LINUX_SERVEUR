# **Étape 9 : Installation de Services Web**

Dans cette étape, nous allons installer plusieurs services web sur **Server2**. Nous commencerons par l'installation de **WordPress** pour `site1.learn-it.local` et `site2.learn-it.local`, puis nous installerons **GLPI** pour `glpi.learn-it.local`.

---

## **Installer WordPress pour `site1.learn-it.local`**

### **1. Télécharger WordPress**

Connectez-vous à **Server2** et téléchargez la dernière version de WordPress :

```bash
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
```

### **2. Installer WordPress**

- **Déplacer les fichiers dans le répertoire approprié :**

  ```bash
  sudo mkdir -p /var/www/site1.learn-it.local
  sudo cp -R /tmp/wordpress/* /var/www/site1.learn-it.local/
  ```

- **Attribuer les permissions correctes :**

  ```bash
  sudo chown -R www-data:www-data /var/www/site1.learn-it.local
  ```

### **3. Créer la base de données pour WordPress**

Connectez-vous à MariaDB en tant que root :

```bash
sudo mysql
```

Dans le shell MariaDB, exécutez les commandes suivantes :

```sql
CREATE DATABASE site1_db;
CREATE USER 'site1_user' IDENTIFIED BY 'password1';
GRANT ALL PRIVILEGES ON site1_db.* TO 'site1_user';
FLUSH PRIVILEGES;
EXIT;
```

### **4. Configurer WordPress**

Cette partie est inutile si vous utilisez l'interface web pour installer wordpress (les droits ayant été donné à www-data, le setup écrira le fichier `w^p-config.php`)

- **Copier le fichier de configuration de base :**

  ```bash
  sudo cp /var/www/site1.learn-it.local/wp-config-sample.php /var/www/site1.learn-it.local/wp-config.php
  ```

- **Éditer le fichier `wp-config.php` :**

  ```bash
  sudo nano /var/www/site1.learn-it.local/wp-config.php
  ```

  - Modifiez les lignes suivantes avec les informations de la base de données :

    ```php
    define( 'DB_NAME', 'site1_db' );
    define( 'DB_USER', 'site1_user' );
    define( 'DB_PASSWORD', 'password1' );
    define( 'DB_HOST', 'localhost' );
    ```

  - **Générer des clés de sécurité uniques :**

    - Visitez [le générateur de clés WordPress](https://api.wordpress.org/secret-key/1.1/salt/) et copiez les lignes générées.
    - Remplacez les lignes correspondantes dans `wp-config.php` par celles que vous avez copiées.

### **5. Configurer le VirtualHost pour `site1.learn-it.local`**

- **Créer le fichier de configuration :**

  ```bash
  sudo nano /etc/apache2/sites-available/site1.learn-it.local.conf
  ```

- **Contenu du fichier :**

  ```apache
  <VirtualHost *:80>
      ServerName site1.learn-it.local
      DocumentRoot /var/www/site1.learn-it.local

      <Directory /var/www/site1.learn-it.local>
          AllowOverride All
          Require all granted
      </Directory>

      ErrorLog ${APACHE_LOG_DIR}/site1_error.log
      CustomLog ${APACHE_LOG_DIR}/site1_access.log combined
  </VirtualHost>
  ```

- **Activer le site `site1.learn-it.local` :**

  ```bash
  sudo a2ensite site1.learn-it.local.conf
  ```

### **7. Configurer les Entrées DNS**

- **Sur `server1` (votre serveur DNS), ajoutez un enregistrement CNAME pour `site1` pointant vers `server2.learn-it.local` dans le fichier de zone directe `/var/lib/bind/zones/db.learn-it.local` :**

  ```bind
  site1   IN      CNAME   server2.learn-it.local.
  ```

- **Incrémentez le numéro de série du SOA dans le fichier de zone :**
Cette partie est utile uniquement lorsque vous avez un serveur secondaire sur votre zone.
  - Modifiez la valeur du `Serial` en l'incrémentant de 1.

- **Redémarrez Bind9 pour appliquer les modifications :**

  ```bash
  sudo systemctl restart bind9
  ```

### **8. Finaliser l'installation de WordPress**

- **Depuis le client Windows, ouvrez un navigateur web et accédez à :**

  ```web
  http://site1.learn-it.local
  ```

- **Suivez les instructions à l'écran pour terminer l'installation de WordPress :**

  - Choisissez la langue.
  - Renseignez le titre du site, le nom d'utilisateur administrateur, le mot de passe et l'adresse e-mail.
  - Terminez l'installation.

---

## **Répéter les Étapes pour `site2.learn-it.local`**

Pour installer WordPress sur `site2.learn-it.local`, répétez les mêmes étapes que pour `site1.learn-it.local`, en apportant les modifications suivantes :

- **Utiliser des noms de base de données, d'utilisateur et de mot de passe distincts :**

  - Base de données : `site2_db`
  - Utilisateur : `site2_user`
  - Mot de passe : `password2`

- **Modifier les chemins et les noms de fichiers de configuration :**

  - Répertoire web : `/var/www/site2.learn-it.local`
  - VirtualHost : `/etc/apache2/sites-available/site2.learn-it.local.conf`

- **Configurer le VirtualHost pour `site2.learn-it.local`** en remplaçant `site1` par `site2`.

- **Ajouter un enregistrement DNS pour `site2`** :

  ```bind
  site2   IN      CNAME   server2.learn-it.local.
  ```

- **Accéder à `http://site2.learn-it.local` depuis le client Windows** et suivre les instructions pour installer WordPress.

---

## **Installer GLPI pour `glpi.learn-it.local`**

### **1. Télécharger GLPI**

Sur **Server2**, téléchargez la dernière version de GLPI :

```bash
cd /tmp
wget https://github.com/glpi-project/glpi/releases/download/10.0.7/glpi-10.0.7.tgz
tar -xzvf glpi-10.0.7.tgz
```

### **2. Installer GLPI**

- **Déplacer les fichiers :**

  ```bash
  sudo mv glpi /var/www/
  ```

- **Renommer le répertoire :**

  ```bash
  sudo mv /var/www/glpi /var/www/glpi.learn-it.local
  ```

- **Attribuer les permissions :**

  ```bash
  sudo chown -R www-data:www-data /var/www/glpi.learn-it.local
  ```

### **3. Créer la base de données pour GLPI**

Connectez-vous à MariaDB en tant que root :

```bash
sudo mysql -u root -p
```

Dans le shell MariaDB, exécutez les commandes suivantes :

```sql
CREATE DATABASE glpi_db;
CREATE USER 'glpi_user' IDENTIFIED BY 'password_glpi';
GRANT ALL PRIVILEGES ON glpi_db.* TO 'glpi_user';
FLUSH PRIVILEGES;
EXIT;
```

### **4. Configurer le VirtualHost pour GLPI**

- **Créer le fichier de configuration :**

  ```bash
  sudo nano /etc/apache2/sites-available/glpi.learn-it.local.conf
  ```

- **Contenu du fichier (selon la documentation officielle) :**

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

### **5. Activer le site et les modules nécessaires**

- **Activer le module `rewrite` d'Apache (si ce n'est pas déjà fait) :**

  ```bash
  sudo a2enmod rewrite
  ```

- **Activer le site `glpi.learn-it.local` :**

  ```bash
  sudo a2ensite glpi.learn-it.local.conf
  ```

- **Installer les extension PHP nécessaire au fonctionnement:**

```bash
sudo apt install php-gd php-intl php-ldap php-bz2 php-zip php-mbstring php-dom php-curl -y
```

- **Configurer PHP:**

```bash
sudo nano /etc/php/8.2/apache2/php.ini
```

Chercher l'instruction `session.cookie_httponly` suivante et ajouter `on` :

```ini
session.cookie_httponly = on
```

- **Redémarrer Apache pour appliquer les changements :**

  ```bash
  sudo systemctl restart apache2
  ```

### **6. Configurer les Entrées DNS**

- **Sur `server1`, ajoutez un enregistrement CNAME pour `glpi` pointant vers `server2.learn-it.local` dans le fichier de zone directe `/var/lib/bind/zones/db.learn-it.local` :**

  ```bind
  glpi    IN      CNAME   server2.learn-it.local.
  ```

- **Incrémentez le numéro de série du SOA dans le fichier de zone :**

  - Modifiez la valeur du `Serial` en l'incrémentant de 1.

- **Redémarrez Bind9 pour appliquer les modifications :**

  ```bash
  sudo systemctl restart bind9
  ```

### **7. Finaliser l'installation de GLPI**

- **Depuis le client Windows, ouvrez un navigateur web et accédez à :**

  ```web
  http://glpi.learn-it.local
  ```

- **Suivez les instructions à l'écran pour installer GLPI :**

  - Sélectionnez la langue.
  - Acceptez les termes de la licence.
  - Vérifiez que toutes les dépendances sont satisfaites.
  - Renseignez les informations de connexion à la base de données :

    - **Serveur de base de données** : `localhost`
    - **Nom de la base** : `glpi_db`
    - **Utilisateur** : `glpi_user`
    - **Mot de passe** : `password_glpi`

  - Poursuivez l'installation en suivant les instructions.

- **Une fois l'installation terminée, connectez-vous avec les identifiants par défaut :**

  - **Utilisateur** : `glpi`
  - **Mot de passe** : `glpi`

### **8. Sécuriser l'installation de GLPI**

- **Supprimez le dossier `install` pour des raisons de sécurité :**

  ```bash
  sudo rm -rf /var/www/glpi.learn-it.local/install
  ```

- **Changez les mots de passe des utilisateurs par défaut (`glpi`, `tech`, `normal`, `post-only`) depuis l'interface d'administration.

---

## **Conclusion**

Vous avez maintenant installé WordPress sur `site1.learn-it.local` et `site2.learn-it.local`, ainsi que GLPI sur `glpi.learn-it.local`. Chaque site est accessible via son propre nom de domaine grâce à la configuration du serveur DNS et des VirtualHosts d'Apache.

---

**Récapitulatif des Étapes :**

1. **Installer WordPress pour `site1.learn-it.local` :**
   - Télécharger et installer WordPress.
   - Créer la base de données et l'utilisateur MariaDB.
   - Configurer WordPress avec les informations de la base de données.
   - Configurer le VirtualHost et les entrées DNS.
   - Finaliser l'installation via le navigateur.

2. **Répéter les étapes pour `site2.learn-it.local` :**
   - Utiliser des noms de bases de données, d'utilisateurs et de mots de passe distincts.

3. **Installer GLPI pour `glpi.learn-it.local` :**
   - Télécharger et installer GLPI.
   - Créer la base de données et l'utilisateur MariaDB.
   - Configurer le VirtualHost et les entrées DNS.
   - Finaliser l'installation via le navigateur.

---

**Prochaines Étapes :**

- **Sécuriser vos sites web :**
  - Mettre à jour WordPress, GLPI et leurs extensions régulièrement.
  - Configurer des certificats SSL pour utiliser HTTPS.
  - Mettre en place des solutions de sauvegarde.

- **Optimiser les performances :**
  - Configurer la mise en cache.
  - Optimiser la base de données.
  - Surveiller les ressources du serveur.

- **Continuer l'apprentissage :**
  - Explorer l'ajout de nouveaux services.
  - Comprendre les logs d'Apache et de PHP pour le dépannage.
  - Approfondir les configurations avancées d'Apache et de MariaDB.

---

**Félicitations pour avoir complété cette étape et mis en place plusieurs services web sur votre serveur !**
