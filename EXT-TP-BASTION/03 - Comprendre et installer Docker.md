# **Étape : Comprendre et installer Docker**

## **Introduction à Docker**

### **Qu'est-ce que Docker ?**

- **Docker** est une plateforme de conteneurisation qui permet d'empaqueter, distribuer et exécuter des applications dans des **conteneurs**.
- Un **conteneur** est un environnement isolé et portable qui contient tout ce qui est nécessaire pour faire fonctionner une application : code, runtime, outils système, bibliothèques et paramètres.
- Docker simplifie le déploiement d'applications en garantissant qu'elles fonctionnent de manière identique sur n'importe quel environnement.

### **Pourquoi utiliser Docker ?**

- **Portabilité** : "Ça fonctionne sur ma machine" → "Ça fonctionne partout"
- **Isolation** : Chaque conteneur est isolé des autres et du système hôte
- **Efficacité** : Utilise moins de ressources que les machines virtuelles traditionnelles
- **Rapidité** : Démarrage quasi instantané des conteneurs
- **Standardisation** : Même environnement du développement à la production
- **Évolutivité** : Facilite la mise à l'échelle des applications

### **Docker vs Machines Virtuelles**

| **Docker (Conteneurs)** | **Machines Virtuelles** |
|-------------------------|-------------------------|
| Partage le noyau de l'OS hôte | Chaque VM a son propre OS complet |
| Démarrage en secondes | Démarrage en minutes |
| Consommation mémoire faible | Consommation mémoire élevée |
| Isolation au niveau processus | Isolation matérielle complète |
| Idéal pour les microservices | Idéal pour l'isolation complète |

## **Concepts fondamentaux**

### **Images Docker**
- **Template** en lecture seule pour créer des conteneurs
- Construites à partir d'un **Dockerfile**
- Stockées dans des **registres** (Docker Hub, etc.)
- Versionnées avec des **tags**

### **Conteneurs**
- **Instance** d'une image Docker en cours d'exécution
- Environnement isolé avec son propre système de fichiers
- Peuvent être démarrés, arrêtés, supprimés

### **Volumes**
- Permettent la **persistance des données** au-delà du cycle de vie d'un conteneur
- Partagés entre conteneurs
- Stockés sur le système hôte

### **Réseaux**
- Permettent la **communication** entre conteneurs
- Isolation réseau par défaut
- Différents types : bridge, host, overlay
### **Docker Compose**
- Outil pour définir et gérer des **applications multi-conteneurs**
- Configuration via un fichier **YAML**
- Orchestre plusieurs services simultanément

#### **Facilités réseau avec Docker Compose**
- **Réseau automatique** : Tous les services définis dans un même fichier `docker-compose.yml` sont connectés à un réseau privé commun, créé automatiquement par Docker Compose.
- **Résolution de noms simplifiée** : Chaque service peut être joint par son **nom de service** comme nom d’hôte (ex : `db`, `web`, etc.), facilitant la communication entre conteneurs sans configuration IP manuelle.
- **Isolation** : Les services ne sont accessibles que depuis ce réseau interne, sauf si des ports sont explicitement exposés vers l’extérieur.
- **Accès entre services** : Les applications peuvent dialoguer entre elles simplement en utilisant le nom du service cible (ex : une application web peut accéder à sa base de données via `db:3306`).
- **Personnalisation** : Possibilité de définir plusieurs réseaux ou de connecter des services à des réseaux externes si besoin.

Exemple d’accès entre services dans un `docker-compose.yml` :
```yaml
services:
    web:
        image: nginx
    db:
        image: mysql
# Le service 'web' peut accéder à 'db' via le nom d’hôte 'db'
```

---

## **Installation de Docker sur Debian 12**

### **Prérequis**

#### **Configuration système requise**

- **Version Debian** : Debian Bookworm 12 (stable)
- **Architecture** : 64-bit (x86_64/amd64)
- **Privilèges** : Accès administrateur (`sudo`)

#### **Considérations sur le pare-feu**

> ⚠️ **ATTENTION - Implications de sécurité**
> 
> - Les ports exposés par Docker **contournent** les règles de pare-feu `ufw` ou `firewalld`
> - Docker est compatible uniquement avec `iptables-nft` et `iptables-legacy`
> - Les règles créées avec `nft` ne sont **pas supportées**

### **Étape 1 : Nettoyage des versions antérieures**

Avant d'installer Docker, il faut supprimer toutes les versions non officielles qui pourraient entrer en conflit.

1. **Désinstaller les paquets conflictuels**

   ```bash
   sudo apt remove docker.io docker-doc docker-compose podman-docker containerd runc
   ```

   > 📝 **Note** : Il est normal que `apt` indique qu'aucun de ces paquets n'est installé.

2. **Supprimer les données existantes (optionnel)**

   Si vous souhaitez un redémarrage complet :

   ```bash
   sudo rm -rf /var/lib/docker
   sudo rm -rf /var/lib/containerd
   ```

   > ⚠️ **ATTENTION** : Cette action supprime définitivement toutes les images, conteneurs et volumes Docker existants.

### **Étape 2 : Installation via le dépôt officiel Docker**

#### **Configuration du dépôt APT**

1. **Mettre à jour les paquets et installer les dépendances**

   ```bash
   sudo apt update
   sudo apt install ca-certificates curl
   ```

2. **Créer le répertoire pour les clés GPG**

   ```bash
   sudo install -m 0755 -d /etc/apt/keyrings
   ```

3. **Télécharger la clé GPG officielle de Docker**

   ```bash
   sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc
   ```

4. **Ajouter le dépôt Docker aux sources APT**

   ```bash
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
     $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
     sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

5. **Mettre à jour la liste des paquets**

   ```bash
   sudo apt update
   ```

#### **Installation des paquets Docker**

1. **Installer Docker Engine et ses composants**

   ```bash
   sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

   **Explication des paquets** :
   - `docker-ce` : Moteur Docker Community Edition
   - `docker-ce-cli` : Interface en ligne de commande
   - `containerd.io` : Runtime de conteneurs
   - `docker-buildx-plugin` : Builder avancé pour images
   - `docker-compose-plugin` : Outil d'orchestration multi-conteneurs

2. **Vérifier l'installation**

   ```bash
   sudo docker run hello-world
   ```

   **Résultat attendu** :
   ```
   Hello from Docker!
   This message shows that your installation appears to be working correctly.
   [...]
   ```

### **Étape 3 : Configuration post-installation**

#### **Permettre l'utilisation de Docker sans `sudo`**

Par défaut, seul `root` peut exécuter des commandes Docker. Pour permettre à votre utilisateur de le faire sans `sudo` :

1. **Ajouter l'utilisateur au groupe `docker`**

   ```bash
   sudo usermod -aG docker $USER
   ```

2. **Appliquer les changements de groupe**

   ```bash
   newgrp docker
   ```

   Ou redémarrez votre session :

   ```bash
   logout
   # Reconnectez-vous
   ```

3. **Tester l'accès sans sudo**

   ```bash
   docker run hello-world
   ```

#### **Configurer le démarrage automatique**

1. **Activer le service Docker au démarrage**

   ```bash
   sudo systemctl enable docker
   ```

2. **Vérifier le statut du service**

   ```bash
   sudo systemctl status docker
   ```

   **Résultat attendu** :
   ```
   ● docker.service - Docker Application Container Engine
        Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; preset: enabled)
        Active: active (running)
   ```

---

## **Vérification et premiers tests**

### **Commandes de base pour tester Docker**

1. **Afficher la version de Docker**

   ```bash
   docker --version
   docker compose version
   ```

2. **Afficher les informations système**

   ```bash
   docker info
   ```

3. **Lister les images disponibles**

   ```bash
   docker images
   ```

4. **Lister les conteneurs en cours d'exécution**

   ```bash
   docker ps
   ```

5. **Lister tous les conteneurs (actifs et arrêtés)**

   ```bash
   docker ps -a
   ```

### **Test d'un conteneur simple**

1. **Exécuter un conteneur Ubuntu interactif**

   ```bash
   docker run -it ubuntu:latest bash
   ```

   - `-i` : Mode interactif
   - `-t` : Alloue un pseudo-TTY
   - `ubuntu:latest` : Image Ubuntu dernière version
   - `bash` : Commande à exécuter

2. **À l'intérieur du conteneur Ubuntu**

   ```bash
   # Vous êtes maintenant dans le conteneur
   cat /etc/os-release
   ls /
   exit  # Pour quitter le conteneur
   ```

3. **Tester un serveur web simple**

   ```bash
   docker run -d -p 8080:80 --name test-nginx nginx:latest
   ```

   - `-d` : Mode détaché (en arrière-plan)
   - `-p 8080:80` : Redirection du port 8080 de l'hôte vers le port 80 du conteneur
   - `--name test-nginx` : Nom du conteneur

4. **Vérifier que le serveur fonctionne**

   ```bash
   curl http://localhost:8080
   ```

   Ou ouvrez un navigateur sur `http://IP_DU_SERVEUR:8080`

5. **Arrêter et supprimer le conteneur de test**

   ```bash
   docker stop test-nginx
   docker rm test-nginx
   ```

---

## **Concepts avancés pour Guacamole**

### **Docker Compose : Orchestration multi-conteneurs**

Pour notre bastion Guacamole, nous utiliserons **Docker Compose** qui permet de :

- **Définir** plusieurs services dans un seul fichier YAML
- **Orchestrer** le démarrage, l'arrêt et la communication entre conteneurs
- **Gérer** les volumes et réseaux de manière centralisée
- **Maintenir** la configuration dans un fichier versionnable

### **Structure type d'un projet Docker Compose**

```
guacamole-bastion/
├── docker-compose.yml    # Configuration des services
├── initdb.sql           # Script d'initialisation de la base de données
├── db/                  # Volume persistant MySQL
└── records/             # Volume des enregistrements de sessions
```

### **Volumes persistants**

Pour Guacamole, nous aurons besoin de :

- **Volume base de données** : `/var/lib/mysql` pour la persistance des configurations
- **Volume enregistrements** : `/var/lib/guacamole/recordings` pour sauvegarder les sessions

### **Réseaux Docker**

- Docker Compose crée automatiquement un **réseau bridge** pour permettre la communication entre conteneurs
- Les conteneurs peuvent se contacter par leur **nom de service**
- Exemple : le conteneur `guacamole` peut contacter `db` directement

---

## **Commandes Docker utiles pour la maintenance**

### **Gestion des images**

```bash
# Lister les images
docker images

# Supprimer une image
docker rmi <nom_image>

# Nettoyer les images non utilisées
docker image prune
```

### **Gestion des conteneurs**

```bash
# Lister les conteneurs actifs
docker ps

# Lister tous les conteneurs
docker ps -a

# Arrêter un conteneur
docker stop <nom_conteneur>

# Supprimer un conteneur
docker rm <nom_conteneur>

# Voir les logs d'un conteneur
docker logs <nom_conteneur>

# Accéder au shell d'un conteneur
docker exec -it <nom_conteneur> bash
```

### **Gestion avec Docker Compose**

> ⚠️ **Attention : Syntaxe des commandes**
>
> Depuis Docker version 20.10+, la commande officielle est `docker compose ...` (avec un espace).  
> L'ancienne syntaxe `docker-compose ...` (avec un tiret) reste compatible mais est dépréciée.  
> Préférez la nouvelle syntaxe pour les environnements récents.

```bash
# Démarrer tous les services
docker compose up -d

# Arrêter tous les services
docker compose down

# Voir les logs de tous les services
docker compose logs

# Voir les logs d'un service spécifique
docker compose logs <nom_service>

# Redémarrer un service
docker compose restart <nom_service>

# Mettre à jour les images
docker compose pull
docker compose up -d
```

### **Nettoyage du système**

```bash
# Nettoyer tous les éléments non utilisés
docker system prune

# Nettoyer en incluant les volumes
docker system prune --volumes

# Voir l'utilisation de l'espace disque
docker system df
```

---

## **Sécurité et bonnes pratiques**

### **Sécurisation de base**

1. **Ne pas exécuter de conteneurs en tant que root**
    ```bash
    # Dans un Dockerfile
    USER 1000:1000
    ```

2. **Limiter les ressources**
    ```bash
    docker run --memory=512m --cpus=1 <image>
    ```

3. **Utiliser des images officielles et à jour**
    ```bash
    docker pull nginx:latest
    ```

---

### **Attention aux images non fiables et à l’utilisation de `:latest`**

L’utilisation d’**images non vérifiées** (provenant de sources inconnues ou même de l’officiel sans vérification) présente des risques majeurs :

- **Logiciels malveillants** : Une image peut contenir des backdoors, des scripts malicieux ou des failles intentionnelles.
- **Fuites de données** : Des images compromises peuvent exfiltrer des secrets, des variables d’environnement ou des fichiers sensibles.
- **Non-conformité** : Certaines images peuvent embarquer des logiciels non conformes à vos politiques de sécurité ou de licences.

Même sur Docker Hub, privilégiez les images **officielles** (avec le badge « Official ») et vérifiez leur provenance et leur Dockerfile.

#### **Risques liés à l’utilisation du tag `:latest`**

- **Imprévisibilité** : Le tag `:latest` ne garantit pas une version précise. Une mise à jour de l’image peut introduire des changements majeurs ou des incompatibilités sans avertissement.
- **Ruptures de compatibilité** : Une nouvelle version poussée sous `:latest` peut casser votre application ou modifier son comportement.
- **Difficulté de debug** : Il devient difficile de reproduire un environnement ou de diagnostiquer un problème si l’image change silencieusement.

**Bonnes pratiques :**
- Utilisez des tags de version explicites (`nginx:1.25.3` plutôt que `nginx:latest`).
- Vérifiez et mettez à jour régulièrement vos images, mais contrôlez le moment et la version.
- Scannez les images avec des outils de sécurité (ex : `docker scan`, Trivy).

---

### **Surveillance et logs**

1. **Configurer la rotation des logs**
   ```bash
   # Dans /etc/docker/daemon.json
   {
     "log-driver": "json-file",
     "log-opts": {
       "max-size": "10m",
       "max-file": "3"
     }
   }
   ```

2. **Surveiller les ressources**
   ```bash
   docker stats
   ```

### **Mise à jour et maintenance**

1. **Mise à jour régulière de Docker**
   ```bash
   sudo apt update
   sudo apt upgrade docker-ce docker-ce-cli containerd.io
   ```

2. **Sauvegarde des volumes**
   ```bash
   docker run --rm -v guacamole_db:/data -v $(pwd):/backup ubuntu tar czf /backup/db-backup.tar.gz -C /data .
   ```

---

## **Dépannage**

### **Problèmes courants**

#### **1. Permission refusée lors de l'exécution de Docker**

**Erreur** :
```
permission denied while trying to connect to the Docker daemon socket
```

**Solution** :
```bash
sudo usermod -aG docker $USER
newgrp docker
```

#### **2. Conflit de ports**

**Erreur** :
```
bind: address already in use
```

**Solution** :
```bash
# Trouver le processus utilisant le port
sudo netstat -tulpn | grep :8080
# Ou utiliser un autre port
docker run -p 8081:80 nginx
```

#### **3. Espace disque insuffisant**

**Erreur** :
```
no space left on device
```

**Solution** :
```bash
docker system prune -a
docker volume prune
```

#### **4. Conteneur qui ne démarre pas**

**Diagnostic** :
```bash
docker logs <nom_conteneur>
docker inspect <nom_conteneur>
```

### **Logs et diagnostic**

1. **Logs du daemon Docker**
   ```bash
   sudo journalctl -u docker.service
   ```

2. **Logs d'un conteneur spécifique**
   ```bash
   docker logs --follow <nom_conteneur>
   ```

3. **Inspection détaillée**
   ```bash
   docker inspect <nom_conteneur>
   ```

---

## **Prochaines étapes**

Une fois Docker installé et testé, vous êtes prêt à :

1. **Comprendre Apache Guacamole** - Architecture et composants
2. **Déployer le bastion** - Configuration Docker Compose
3. **Configurer les connexions** - RDP, SSH, VNC
4. **Sécuriser l'accès** - HTTPS et authentification

---

## **Ressources complémentaires**

- [Documentation officielle Docker](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Meilleures pratiques Dockerfile](https://docs.docker.com/develop/dev-best-practices/)
- [Sécurité Docker](https://docs.docker.com/engine/security/)
- [Docker Hub](https://hub.docker.com/) - Registre d'images officielles
