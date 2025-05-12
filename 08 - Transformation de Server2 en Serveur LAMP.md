# **Étape 8 : Transformation de server2 en serveur LAMP**

Dans cette étape, nous allons transformer **Server2** en un serveur web complet en installant une pile **LAMP** (Linux, Apache, MariaDB, PHP). Avant de procéder à l'installation, il est important de comprendre les composants de cette pile, leur rôle, et comment ils interagissent pour servir des pages web dynamiques.

## **Comprendre le protocole HTTP et les serveurs web**

### **Le protocole HTTP**

- **HTTP (HyperText Transfer Protocol)** est le protocole de communication utilisé sur le World Wide Web. Il définit comment les messages sont formatés et transmis, et quelles actions les serveurs web et les navigateurs doivent prendre en réponse à diverses commandes.

- **Fonctionnement de base :**

  1. **Client HTTP (navigateur web) :**
     - L'utilisateur saisit une URL dans le navigateur ou clique sur un lien.
     - Le navigateur construit une requête HTTP en utilisant la méthode appropriée (GET, POST, etc.).
     - La requête est envoyée au serveur web via le réseau.

  2. **Serveur HTTP :**
     - Reçoit la requête HTTP du client.
     - Traite la requête en fonction du type de ressource demandée (fichier statique, script dynamique).
     - Génère une réponse HTTP avec un code de statut (200 OK, 404 Not Found, etc.) et le contenu approprié.

  3. **Communication client-serveur :**
     - Basée sur le modèle **requête-réponse**.
     - Utilise le protocole TCP/IP pour établir la connexion et transférer les données.

### **Interactions entre le client HTTP et le serveur**

- **Étapes du processus :**

  1. **Résolution DNS :**
     - Le client résout le nom de domaine du serveur en adresse IP.

  2. **Établissement de la connexion :**
     - Le client établit une connexion TCP avec le serveur sur le port 80 (HTTP) ou 443 (HTTPS).

  3. **Envoi de la requête HTTP :**
     - Le client envoie une requête HTTP comprenant :
       - **Méthode** : GET, POST, PUT, DELETE, etc.
       - **URI** : Chemin de la ressource demandée.
       - **En-têtes** : Informations supplémentaires (User-Agent, Accept, etc.).
       - **Corps** : Contenu des données pour les requêtes comme POST.

  4. **Traitement par le serveur :**
     - Le serveur lit la requête et détermine comment y répondre.
     - S'il s'agit d'un fichier statique, il le lit et le renvoie.
     - S'il s'agit d'un script (par exemple, PHP), il exécute le code et génère le contenu dynamiquement.

  5. **Envoi de la réponse HTTP :**
     - Le serveur envoie une réponse HTTP comprenant :
       - **Code de Statut** : 200 OK, 404 Not Found, etc.
       - **En-têtes** : Type de contenu, longueur, etc.
       - **Corps** : Le contenu de la page ou le message d'erreur.

  6. **Clôture de la connexion :**
     - La connexion TCP peut être maintenue pour des requêtes ultérieures (keep-alive) ou fermée.

### **Place d'apache2 sur le marché des serveurs Web**

- **Apache HTTP Server (Apache2)** :
  - L'un des serveurs web les plus populaires au monde.
  - Open-source, robuste, et hautement configurable.
  - Supporte une large gamme de modules pour étendre ses fonctionnalités.

- **Comparaison avec Nginx :**

  - **Nginx** :
    - Serveur web et proxy inverse performant.
    - Connu pour sa gestion efficace des connexions concurrentes.
    - Souvent utilisé pour servir des fichiers statiques ou en tant que proxy pour des applications web.

  - **Apache2** :
    - Offre une grande flexibilité grâce à sa modularité.
    - Peut gérer des scripts dynamiques via des modules comme mod_php.
    - Souvent utilisé en conjonction avec des applications nécessitant des fonctionnalités avancées.

- **Choix du serveur web :**
  - Le choix entre Apache2 et Nginx dépend des besoins spécifiques du projet.
  - Apache2 est souvent préféré pour sa facilité de configuration et sa compatibilité avec de nombreux modules.
  - Nginx est choisi pour sa performance et son utilisation de ressources réduite.

## **Comprendre le rôle de PHP et son interaction avec Apache**

### **Qu'est-ce que PHP ?**

- **PHP (Hypertext Preprocessor)** :
  - Langage de script côté serveur.
  - Conçu pour le développement web.
  - Permet de créer des pages web dynamiques en intégrant du code PHP dans des pages HTML.

### **Interaction entre PHP et Apache**

- **Modules d'intégration :**
  - **mod_php** :
    - Module Apache qui permet d'interpréter le code PHP directement au sein du serveur web.
    - Les scripts PHP sont exécutés par Apache lors du traitement des requêtes.

- **Processus de traitement :**

  1. **Requête pour un script PHP :**
     - Le client demande une page avec une extension `.php`.

  2. **Apache identifie le handler :**
     - Grâce à la configuration, Apache sait qu'il doit traiter les fichiers `.php` avec le module PHP.

  3. **Exécution du code PHP :**
     - Le module PHP interprète le code, exécute les instructions, et génère du contenu dynamique.

  4. **Retour de la réponse :**
     - Le résultat de l'exécution (généralement du HTML) est renvoyé au client via Apache.

### **Intérêt de PHP**

- **Dynamisme :**
  - Génère du contenu en fonction des interactions utilisateur ou des données en base.

- **Interaction avec les bases de données :**
  - PHP peut se connecter à des bases de données comme MariaDB pour stocker et récupérer des informations.

- **Large adoption :**
  - Utilisé par de nombreux CMS populaires (WordPress, Drupal, Joomla).
  - Dispose d'une vaste communauté et de nombreuses bibliothèques.

## **Comprendre le rôle de MariaDB**

### **Qu'est-ce que MariaDB ?**

- **MariaDB** :
  - Système de gestion de bases de données relationnelles (SGBDR) open-source.
  - Fork de MySQL, offrant des améliorations en termes de performance et de fonctionnalités.
  - Utilise le langage SQL pour manipuler les données.

### **Interaction entre PHP et MariaDB**

- **Connexion :**
  - Les scripts PHP utilisent des extensions (comme `mysqli` ou `PDO`) pour se connecter à MariaDB.

- **Exécution de requêtes :**
  - Les scripts exécutent des requêtes SQL pour interagir avec la base de données.

- **Traitement des données :**
  - Les résultats sont traités par PHP pour afficher des informations dynamiques à l'utilisateur.

### **Importance de MariaDB dans la pile LAMP**

- **Stockage persistant :**
  - Permet de conserver des données sur le long terme (utilisateurs, articles, commandes).

- **Gestion de données complexes :**
  - Supporte les transactions, les relations entre tables, les procédures stockées.

- **Performance :**
  - Optimisé pour les applications web avec de nombreuses connexions simultanées.

## **Installer Apache, MariaDB et PHP**

### **1. Installer les paquets nécessaires**

Exécutez la commande suivante :

```bash
sudo apt install apache2 mariadb-server php libapache2-mod-php php-mysql
```

- **apache2** : Serveur web Apache.
- **mariadb-server** : Serveur de base de données MariaDB.
- **php** : Langage de script PHP.
- **libapache2-mod-php** : Module pour intégrer PHP avec Apache.
- **php-mysql** : Extension PHP pour interagir avec MariaDB.

### **2. Vérifier l'état des services**

Assurez-vous que les services sont actifs :

```bash
sudo systemctl status apache2
sudo systemctl status mariadb
```

- Si un service n'est pas actif, démarrez-le :

  ```bash
  sudo systemctl start apache2
  sudo systemctl start mariadb
  ```

### **3. Sécuriser MariaDB**

Exécutez le script de sécurisation :

```bash
sudo mysql_secure_installation
```

- **Étapes à suivre :**
  - **Définir un mot de passe root pour MariaDB** : Choisissez un mot de passe sécurisé.
  - **Supprimer les utilisateurs anonymes** : Répondez **Oui**.
  - **Désactiver l'accès root à distance** : Répondez **Oui**.
  - **Supprimer la base de données de test** : Répondez **Oui**.
  - **Recharger les tables de privilèges** : Répondez **Oui**.

### **4. Tester l'installation**

#### **Vérifier Apache**

- Ouvrez un navigateur web sur le **client Windows**.
- Accédez à l'adresse :

  ```ini
  http://server2.learn-it.local/
  ```

- Vous devriez voir la page par défaut d'Apache indiquant que le serveur fonctionne.

#### **Tester PHP**

- Créez un fichier de test :

  ```bash
  sudo nano /var/www/html/info.php
  ```

- Ajoutez le contenu suivant :

  ```php
  <?php
  phpinfo();
  ?>
  ```

- Accédez à :

  ```ini
  http://server2.learn-it.local/info.php
  ```

- Vous devriez voir une page détaillant la configuration de PHP.

- **Important** : Supprimez le fichier après le test pour des raisons de sécurité.

  ```bash
  sudo rm /var/www/html/info.php
  ```

## **Comprendre les services sous Linux et la gestion des permissions**

### **Services et systemd**

- **systemd** est le système d'initialisation et de gestion des services sous Debian 12.

- **Commandes utiles :**

  - **Démarrer un service :**

    ```bash
    sudo systemctl start nom_du_service
    ```

  - **Arrêter un service :**

    ```bash
    sudo systemctl stop nom_du_service
    ```

  - **Redémarrer un service :**

    ```bash
    sudo systemctl restart nom_du_service
    ```

  - **Recharger la configuration d'un service (sans interrompre les connexions) :**

    ```bash
    sudo systemctl reload nom_du_service
    ```

  - **Vérifier l'état d'un service :**

    ```bash
    sudo systemctl status nom_du_service
    ```

### **Gestion des permissions**

- **Utilisateur et groupe www-data :**

  - Apache fonctionne sous l'utilisateur et le groupe `www-data`.

- **Permissions sur les fichiers web :**

  - Les fichiers du site doivent appartenir à `www-data` pour qu'Apache puisse y accéder.

  - **Changer le propriétaire :**

    ```bash
    sudo chown -R www-data:www-data /var/www/nom_du_site
    ```

  - **Exemple :**

    ```bash
    sudo chown -R www-data:www-data /var/www/site1.learn-it.local
    ```

- **Permissions des fichiers et répertoires :**

  - **Répertoires** : Permissions typiques `755` (rwxr-xr-x).

  - **Fichiers** : Permissions typiques `644` (rw-r--r--).

  - **Modifier les permissions :**

    ```bash
    sudo chmod -R 755 /var/www/nom_du_site
    sudo find /var/www/nom_du_site -type f -exec chmod 644 {} \;
    ```

## **Conclusion**

Vous avez transformé **Server2** en un serveur web LAMP fonctionnel, capable de servir des pages web dynamiques grâce à Apache, PHP, et MariaDB. Vous comprenez maintenant le rôle de chaque composant et comment ils interagissent pour fournir des services web complets.

---

**Prochaines étapes :**

- **Installer des applications web** : WordPress, Joomla, GLPI, etc.

- **Configurer les VirtualHosts** pour héberger plusieurs sites sur le même serveur.

- **Sécuriser le serveur** : Configurer SSL/TLS, mettre en place des pare-feux, surveiller les logs.

- **Optimiser les performances** : Cache PHP, optimisation de la base de données, compression des ressources.

---

**Remarques finales :**

- **Documentation** : Consultez la documentation officielle pour approfondir vos connaissances.

- **Mises à jour** : Maintenez votre système et vos applications à jour pour bénéficier des dernières fonctionnalités et correctifs de sécurité.

- **Sauvegardes** : Mettez en place des stratégies de sauvegarde pour vos bases de données et vos fichiers.

---

**Félicitations pour cette étape importante dans la construction de votre infrastructure réseau et web !**
