# 05 - Sécurisation Guacamole (TOTP et HTTPS)

## 🔐 Authentification TOTP (2FA)

### Qu'est-ce que l'authentification à deux facteurs ?

L'**authentification à deux facteurs** renforce la sécurité en combinant :
- **Quelque chose que vous connaissez** : mot de passe (facteur de connaissance)
- **Quelque chose que vous possédez** : téléphone/token (facteur de possession)

**Avantages de la 2FA :**
- ✅ Protection contre le vol de mots de passe
- ✅ Réduction des attaques par force brute
- ✅ Conformité réglementaire
- ✅ Traçabilité renforcée

### ⏰ Le protocole TOTP

**TOTP** est un algorithme standardisé (**RFC 6238**) qui génère des codes à usage unique basés sur le temps.

**Principe :**
1. Secret partagé entre serveur et application mobile
2. Horodatage comme base de calcul
3. HMAC (SHA-1) et fenêtre temporelle (souvent 30s)
4. Code final à 6 chiffres

### Implémentation TOTP dans Guacamole

Ajouter les variables d'environnement dans le service `guacamole` :

```yaml
guacamole:
  image: guacamole/guacamole
  restart: always
  environment:
    # ...existing code...
    TOTP_ENABLED: 'true'
    TOTP_ISSUER: 'Bastion-Guacamole'
    TOTP_DIGITS: '6'
    TOTP_PERIOD: '30'
```

Redémarrer et vérifier :

```bash
# Arrêter le service Guacamole
docker compose down guacamole

# Redémarrer avec la nouvelle configuration
docker compose up -d guacamole

docker compose logs guacamole | grep -i totp
```

Première connexion : saisir identifiant/mot de passe puis le code TOTP affiché dans l'application mobile.

#### Dépannage & bonnes pratiques

- "Code invalide" : vérifier l'heure système (NTP)
- QR code illisible : utiliser la clé secrète textuelle
- Perte du téléphone : prévoir des codes de récupération
- Codes de récupération et obligation TOTP pour tous les comptes en production

#### Exemple synthétique

```yaml
services:
  guacamole:
    image: guacamole/guacamole
    restart: always
    environment:
      GUACD_HOSTNAME: guacd
      MYSQL_HOSTNAME: db
      MYSQL_DATABASE: guacamoledb
      MYSQL_USER: user
      MYSQL_PASSWORD: Azerty01
      TOTP_ENABLED: 'true'
      TOTP_ISSUER: 'Bastion-Entreprise'
      RECORDING_SEARCH_PATH: /var/lib/guacamole/recordings
      HISTORY_PATH: /var/lib/guacamole/recordings
    ports:
      - 8080:8080
    volumes:
      - ./records:/var/lib/guacamole/recordings
```

> Activer TOTP **avant** la mise en production et synchroniser l'heure système (NTP).

---

## 🔐 Sécurisation HTTPS avec reverse proxy

Guacamole expose son interface en **HTTP sur port 8080**. Un **reverse proxy** (Nginx/Traefik/Apache) apporte chiffrement TLS, filtrage et journalisation centralisée.

### Prérequis production
- IP publique et enregistrement DNS (ex: `bastion.entreprise.com`)
- Certificats TLS (Let's Encrypt/Certbot ou équivalent)

### Exemple Nginx minimal

```nginx
server {
    listen 80;
    server_name bastion.entreprise.com;

    location / {
        proxy_pass http://localhost:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Activation et certificat :

```bash
sudo ln -s /etc/nginx/sites-available/guacamole /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
sudo certbot --nginx -d bastion.entreprise.com
```

Certbot ajoute automatiquement la redirection HTTP→HTTPS et les certificats TLS.

### Gestion des accès utilisateur

- Désactiver le compte `guacadmin` en production
- Intégrer l'authentification via LDAP/AD ou SSO
- Appliquer le principe du moindre privilège et auditer régulièrement
- Changer tous les mots de passe par défaut
