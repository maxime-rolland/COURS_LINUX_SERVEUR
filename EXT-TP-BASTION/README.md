# 🐳 Déployer un bastion sécurisé avec Apache Guacamole et Docker

## 🎯 Objectifs pédagogiques

- Comprendre le rôle d’un **bastion d’accès distant**.
- Mettre en œuvre un bastion **via Apache Guacamole**.
- Utiliser **Docker et Docker Compose** pour faciliter le déploiement.
- Sécuriser les accès via **HTTPS** et enregistrer les sessions pour assurer l’**imputabilité**.

---

## 🚀 Pourquoi utiliser Docker pour Guacamole ?

### ✅ Avantages de Docker + Docker Compose

- **Portabilité** : un environnement reproductible sur n’importe quelle machine.
- **Isolation** : chaque service tourne dans un conteneur indépendant.
- **Maintenance facilitée** : mises à jour, sauvegardes, rollback simplifiés.
- **Déploiement rapide** : un seul fichier `docker-compose.yml` permet d'orchestrer l'ensemble.

---

## 🛡️ Rappel : rôle d’un bastion

Le bastion agit comme **point d’entrée unique** et **contrôlé** vers le système d’information.  
Avec **Guacamole**, ce bastion devient accessible **depuis un navigateur**, sans client lourd, et offre des fonctions de :

- **centralisation des accès**,
- **enregistrement des sessions RDP/SSH**,
- **authentification centralisée (LDAP/SSO)**,
- **audits et traçabilité**.

---

## 📦 Fichier `docker-compose.yml` commenté

```yaml

services:

  # Service guacd : serveur de connexions à distance (backend Guacamole)
  guacd:
    image: guacamole/guacd
    restart: always
    environment:
      GUACD_LOG_LEVEL: debug  # Niveau de log utile pour le debug
    volumes:
      - ./records:/var/lib/guacamole/recordings  # Dossier d'enregistrement des sessions

  # Service Guacamole Web : interface utilisateur (port 8080 ici, souvent proxifié ensuite via HTTPS)
  guacamole:
    image: guacamole/guacamole
    restart: always
    group_add:
      - 1000  # Groupe utilisé pour permettre l’écriture dans le volume d'enregistrement
    environment:
      GUACD_HOSTNAME: guacd  # Lien vers le backend guacd
      RECORDING_SEARCH_PATH: /var/lib/guacamole/recordings  # Accès aux enregistrements via l’interface
      HISTORY_PATH: /var/lib/guacamole/recordings  # Historique des connexions
      MYSQL_HOSTNAME: db  # Adresse du service MySQL
      MYSQL_DATABASE: guacamoledb
      MYSQL_USER: user
      MYSQL_PASSWORD: Azerty01
    ports:
      - 8080:8080  # À sécuriser via HTTPS avec un reverse proxy
    volumes:
      - ./records:/var/lib/guacamole/recordings

  # Base de données MySQL : stocke la configuration, les utilisateurs, l’historique Guacamole
  db:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_DATABASE: guacamoledb
      MYSQL_USER: user
      MYSQL_PASSWORD: Azerty01
      MYSQL_RANDOM_ROOT_PASSWORD: '1'  # Génère un mot de passe root aléatoire (à éviter en prod)
    volumes:
      - ./db:/var/lib/mysql  # Volume persistant pour les données
      - ./initdb.sql:/initdb.sql  # Script d'init optionnel (non exécuté automatiquement ici)
````

---

## 🎥 Enregistrement des sessions : un levier de cybersécurité

### ✨ Fonction activée ici via

- `RECORDING_SEARCH_PATH`
- `HISTORY_PATH`
- Volume partagé `./records:/var/lib/guacamole/recordings`

### 🔍 Intérêt opérationnel

- ✅ **Imputabilité** : savoir *qui a fait quoi, quand et sur quelle machine*.
- ✅ **Auditabilité** : rejouer une session suspecte.
- ✅ **Conformité** : RGPD, ISO 27001, ANSSI, etc.
- ✅ **Formation** : observer les erreurs, reproduire les manipulations.

---

## 🔐 À sécuriser absolument

### HTTPS

- Guacamole expose ici son interface en **HTTP sur port 8080**, non sécurisé.
- Il est recommandé d’ajouter un **reverse proxy** (ex : **Nginx**, **Traefik**) devant Guacamole :

  - Rediriger le trafic HTTP vers HTTPS.
  - Ajouter un **certificat SSL/TLS** via Let's Encrypt ou ACME.
  - Exemple avec Nginx :

    ```nginx
    server {
        listen 443 ssl;
        server_name guac.domain.local;

        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;

        location / {
            proxy_pass http://localhost:8080/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
    ```

### Accès utilisateur

- ❌ Ne jamais laisser le compte **guacadmin** actif.
- ✅ Intégrer l’authentification via **LDAP/AD** ou un gestionnaire d'identité.
- ✅ Appliquer le **principe du moindre privilège**.
- ✅ Auditer les connexions et droits régulièrement.

---

## 🧪 Atelier proposé aux étudiants

> **Objectif** : Déployer un bastion avec Guacamole et enregistrer les accès.

### Étapes

1. Cloner un dépôt contenant `docker-compose.yml`
2. Démarrer les conteneurs :

   ```bash
   docker compose up -d
   ```

3. Accéder à l’interface : `http://localhost:8080/guacamole`
4. Ajouter une connexion RDP vers une VM locale (Windows)
5. Tester une session et vérifier la création de fichiers `.mkv` dans `./records`
6. Bonus : mettre en place un reverse proxy HTTPS avec certificat auto-signé

---

## 📚 Ressources complémentaires

- [Documentation Apache Guacamole](https://guacamole.apache.org/doc/)
- [Guacamole Docker GitHub Repo](https://github.com/oznu/docker-guacamole)
- [Best practices sécurité ANSSI](https://www.ssi.gouv.fr)
- [Fail2ban + Docker](https://hub.docker.com/r/crazymax/fail2ban)
- [Nginx + Let's Encrypt (Certbot)](https://certbot.eff.org/)
