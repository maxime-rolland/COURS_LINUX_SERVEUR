# **Étape 7 : Transformation de server1 en serveur DHCP avec Kea**

Dans cette étape, nous allons transformer **server1** en serveur DHCP en utilisant **Kea**, et mettre en place les mises à jour DNS dynamiques (DDNS) afin que les baux DHCP soient automatiquement enregistrés dans notre serveur DNS. Avant de procéder à la configuration, il est essentiel de comprendre le fonctionnement du protocole DHCP.

## **Comprendre le fonctionnement du protocole DHCP**

### **Qu'est-ce que le DHCP ?**

Le **DHCP** (Dynamic Host Configuration Protocol) est un protocole réseau qui permet aux clients d'obtenir automatiquement les paramètres de configuration IP nécessaires pour communiquer sur un réseau. Ces paramètres incluent :

- **Adresse IP**
- **Masque de sous-réseau**
- **Passerelle par défaut**
- **Serveurs DNS**
- **Autres options spécifiques**

### **Fonctionnement du DHCP : Interactions client/serveur**

Le processus DHCP suit une séquence d'échanges entre le client et le serveur, souvent décrite par l'acronyme **DORA** :

1. **Discovery (Découverte)** : Le client envoie un message **DHCPDISCOVER** en diffusion (broadcast) pour localiser les serveurs DHCP disponibles sur le réseau.

2. **Offer (Offre)** : Les serveurs DHCP répondent avec un message **DHCPOFFER**, proposant une configuration IP au client.

3. **Request (Demande)** : Le client choisit une offre et envoie un message **DHCPREQUEST** pour demander la configuration proposée.

4. **Acknowledgment (Accusé de réception)** : Le serveur confirme la configuration avec un message **DHCPACK**, finalisant le processus.

**Schéma du processus DORA :**

```
Client                              Serveur DHCP
   |                                      |
   | -- DHCPDISCOVER (broadcast) -->      |
   |                                      |
   | <-- DHCPOFFER (broadcast) --------   |
   |                                      |
   | -- DHCPREQUEST (broadcast) -->       |
   |                                      |
   | <-- DHCPACK (broadcast) ----------   |
   |                                      |
```

**Détails des messages :**

- **DHCPDISCOVER** : Le client recherche les serveurs DHCP sur le réseau.
- **DHCPOFFER** : Le serveur propose une adresse IP et des paramètres de configuration.
- **DHCPREQUEST** : Le client accepte l'offre du serveur et demande la configuration.
- **DHCPACK** : Le serveur confirme la configuration et l'allocation de l'adresse IP.

### **Rôles du serveur et du client DHCP**

- **Serveur DHCP :**

  - Gère un pool d'adresses IP disponibles pour les clients.
  - Alloue des adresses IP aux clients selon des politiques définies.
  - Fournit des informations de configuration supplémentaires (passerelle, DNS, etc.).
  - Gère la durée des baux (leases) et le renouvellement des adresses IP.

- **Client DHCP :**

  - Demande une configuration réseau au serveur DHCP.
  - Renouvelle son bail périodiquement avant expiration.
  - Libère l'adresse IP lorsqu'il n'en a plus besoin (par exemple, à l'extinction).

## **Configurer Kea DHCP pour votre réseau**

### **1. Installer Kea DHCP**

Installez les paquets nécessaires :

```bash
sudo apt install kea-dhcp4-server kea-dhcp-ddns-server
```

- **`kea-dhcp4-server`** : Serveur DHCP pour IPv4.
- **`kea-dhcp-ddns-server`** : Serveur Kea pour les mises à jour DNS dynamiques (DDNS).

### **2. Configurer Kea DHCP**

#### **Fichier de configuration du serveur DHCP : `/etc/kea/kea-dhcp4.conf`**

1. **Éditer le fichier de configuration :**

   ```bash
   sudo nano /etc/kea/kea-dhcp4.conf
   ```

2. **Contenu du fichier avec commentaires :**

   ```jsonc
   {
     "Dhcp4": {
       // Configuration des interfaces sur lesquelles le serveur DHCP écoute
       "interfaces-config": {
         "interfaces": ["enp0s8"] // Remplacez par le nom de votre interface interne
       },

       // Configuration de la base de données des baux DHCP
       "lease-database": {
         "type": "memfile",
         "persist": true,
         "name": "/var/lib/kea/kea-leases4.csv"
       },

       // Durée de validité des baux en secondes (ici 10 minutes)
       "valid-lifetime": 600,

       // Définition des sous-réseaux gérés par le serveur DHCP
       "subnet4": [
         {
           "subnet": "192.168.200.0/24",
           // Plage d'adresses IP à allouer aux clients
           "pools": [{ "pool": "192.168.200.100 - 192.168.200.110" }],
           // Options DHCP à fournir aux clients
           "option-data": [
             { "name": "routers", "data": "192.168.200.254" }, // Passerelle par défaut
             { "name": "domain-name", "data": "learn-it.local" }, // Nom de domaine
             { "name": "domain-name-servers", "data": "192.168.200.254" } // Serveur DNS
           ],
           // Configuration des mises à jour DNS dynamiques
           "ddns": {
             "enable-updates": true,
             "qualifying-suffix": "learn-it.local.",
             "hostname": "%{hostname}.learn-it.local.",
             "override-no-update": true
           }
         }
       ],

       // Configuration du serveur DHCP-DDNS pour les mises à jour DNS
       "dhcp-ddns": {
         "enable-ddns": true,
         "server-ip": "127.0.0.1",
         "server-port": 53001,
         "max-queue-size": 100
       }
     }
   }
   ```

   **Explications :**

   - **`interfaces-config`** : Spécifie l'interface réseau sur laquelle le serveur DHCP écoute. Remplacez `"enp0s8"` par le nom de votre interface interne.
   - **`lease-database`** : Configure la base de données des baux. Ici, nous utilisons un fichier en mémoire (`memfile`).
   - **`valid-lifetime`** : Durée en secondes pendant laquelle un bail est valide.
   - **`subnet4`** : Définit le sous-réseau géré, les plages d'adresses IP, les options DHCP et les paramètres de mise à jour DNS.
   - **`ddns`** : Active les mises à jour DNS dynamiques pour les clients de ce sous-réseau.
   - **`dhcp-ddns`** : Configure la communication avec le serveur Kea DHCP-DDNS pour les mises à jour DNS.

#### **Fichier de configuration du serveur DHCP-DDNS : `/etc/kea/kea-dhcp-ddns.conf`**

1. **Éditer le fichier de configuration :**

   ```bash
   sudo nano /etc/kea/kea-dhcp-ddns.conf
   ```

2. **Contenu du fichier avec commentaires :**

   ```jsonc
   {
     "DhcpDdns": {
       // Configuration des niveaux de journalisation
       "loggers": [
         {
           "name": "kea-dhcp-ddns",
           "output_options": [{ "output": "stdout" }],
           "severity": "INFO",
           "debuglevel": 0
         }
       ],

       // Configuration du socket de contrôle
       "control-socket": {
         "socket-type": "unix",
         "socket-name": "/run/kea/kea-dhcp-ddns.sock"
       },

       // Adresse IP et port sur lesquels le serveur DHCP-DDNS écoute
       "ip-address": "127.0.0.1",
       "port": 53001,

       // Clés TSIG pour sécuriser les mises à jour DNS
       "tsig-keys": [
         {
           "name": "kea_ddns",
           "algorithm": "HMAC-SHA256",
           "secret": "VOTRE_CLÉ_SECRÈTE_IÇI" // Remplacez par la clé générée
         }
       ],

       // Configuration des mises à jour DNS directes
       "forward-ddns": {
         "ddns-domains": [
           {
             "name": "learn-it.local.",
             "key-name": "kea_ddns",
             "dns-server": { "ip-address": "127.0.0.1", "port": 53 }
           }
         ]
       },

       // Configuration des mises à jour DNS inverses
       "reverse-ddns": {
         "ddns-domains": [
           {
             "name": "200.168.192.in-addr.arpa.",
             "key-name": "kea_ddns",
             "dns-server": { "ip-address": "127.0.0.1", "port": 53 }
           }
         ]
       }
     }
   }
   ```

   **Explications :**

   - **`tsig-keys`** : Définit les clés TSIG utilisées pour sécuriser les mises à jour DNS. La clé doit correspondre à celle configurée dans BIND.
   - **`forward-ddns`** : Configure les mises à jour DNS pour les enregistrements de type A (résolution directe).
   - **`reverse-ddns`** : Configure les mises à jour DNS pour les enregistrements de type PTR (résolution inverse).
   - **`ddns-domains`** : Spécifie les domaines à mettre à jour et les serveurs DNS correspondants.

### **3. Générer une Clé TSIG pour Sécuriser les Mises à Jour DNS**

Les mises à jour DNS dynamiques doivent être sécurisées pour empêcher les mises à jour non autorisées. Nous utilisons des clés **TSIG** (Transaction SIGnature) pour authentifier les communications entre Kea et BIND.

#### **Générer la clé TSIG**

1. **Utiliser `dnssec-keygen` pour générer la clé :**

   ```bash
   sudo dnssec-keygen -a HMAC-SHA256 -b 256 -n HOST kea_ddns
   ```

   - **`-a HMAC-SHA256`** : Spécifie l'algorithme de hachage.
   - **`-b 256`** : Taille de la clé en bits.
   - **`-n HOST`** : Type de clé (hôte).
   - **`kea_ddns`** : Nom de la clé.

2. **Récupérer la clé générée :**

   Deux fichiers sont créés, par exemple :

   ```bash
   Kkea_ddns.+163+12345.key
   Kkea_ddns.+163+12345.private
   ```

3. **Extraire le secret de la clé :**

   ```bash
   sudo cat Kkea_ddns.+163+*.private | grep Key: | awk '{print $2}'
   ```

   - Copiez la valeur de la clé secrète (une chaîne encodée en Base64).

#### **Configurer BIND pour accepter les mises à jour dynamiques**

1. **Déplacer la clé dans le répertoire de configuration de BIND :**

   ```bash
   sudo mkdir -p /etc/bind/keys
   sudo mv Kkea_ddns.+163+*.key /etc/bind/keys/kea_ddns.key
   sudo mv Kkea_ddns.+163+*.private /etc/bind/keys/kea_ddns.private
   ```

2. **Éditer le fichier `/etc/bind/named.conf.local` :**

   ```bash
   sudo nano /etc/bind/named.conf.local
   ```

   Ajoutez la configuration pour la clé TSIG et mettez à jour les zones :

   ```bind
   key "kea_ddns" {
       algorithm hmac-sha256;
       secret "VOTRE_CLÉ_SECRÈTE_IÇI"; // Remplacez par la clé secrète
   };

   zone "learn-it.local" IN {
       type master;
       file "/var/lib/bind/zones/db.learn-it.local";
       // Autoriser les mises à jour dynamiques sécurisées
       update-policy {
           grant kea_ddns zonesub ANY;
       };
   };

   zone "200.168.192.in-addr.arpa" IN {
       type master;
       file "/var/lib/bind/zones/db.192.168.200";
       // Autoriser les mises à jour dynamiques sécurisées
       update-policy {
           grant kea_ddns zonesub ANY;
       };
   };
   ```

   **Explications :**

   - **`key`** : Déclare la clé TSIG avec son nom, son algorithme et le secret.
   - **`update-policy`** : Autorise les mises à jour dynamiques des zones par les entités qui présentent la clé `kea_ddns`.

3. **Vérifier la configuration de BIND :**

   ```bash
   sudo named-checkconf
   ```

   Corrigez toute erreur éventuelle.

4. **Redémarrer BIND :**

   ```bash
   sudo systemctl restart bind9
   ```

### **4. Démarrer et activer les services Kea**

1. **Démarrer le serveur DHCP-DDNS :**

   ```bash
   sudo systemctl enable kea-dhcp-ddns-server
   sudo systemctl start kea-dhcp-ddns-server
   ```

2. **Démarrer le serveur DHCP4 :**

   ```bash
   sudo systemctl enable kea-dhcp4-server
   sudo systemctl start kea-dhcp4-server
   ```

### **5. Vérifier les configurations et les logs**

- **Vérifier les logs de Kea DHCP4 :**

  ```bash
  sudo journalctl -u kea-dhcp4-server
  ```

- **Vérifier les logs de Kea DHCP-DDNS :**

  ```bash
  sudo journalctl -u kea-dhcp-ddns-server
  ```

- **Vérifier les logs de BIND :**

  ```bash
  sudo journalctl -u bind9
  ```

- **Analyser les logs pour détecter d'éventuelles erreurs ou problèmes de communication.**

## **Tester le fonctionnement du DHCP avec mises à jour DNS dynamiques**

1. **Configurer le client Windows pour obtenir une IP automatiquement**

   - Dans les paramètres réseau du client Windows, assurez-vous que l'option "Obtenir une adresse IP automatiquement" est sélectionnée.

2. **Vérifier que le client obtient une adresse IP**

   - Ouvrez une invite de commandes sur le client Windows et exécutez :

     ```cmd
     ipconfig /all
     ```

   - Vérifiez que l'adresse IP attribuée est dans la plage `192.168.200.100 - 192.168.200.110`.

3. **Vérifier la résolution DNS depuis server1**

   - Sur **server1**, exécutez :

     ```bash
     dig client.learn-it.local
     ```

   - Vous devriez voir que `client.learn-it.local` résout à l'adresse IP attribuée au client Windows.

4. **Vérifier les enregistrements DNS sur le serveur**

   - Les mises à jour dynamiques modifient les fichiers de zone. Vous pouvez consulter le fichier de zone pour vérifier que l'enregistrement a été ajouté.

     ```bash
     sudo cat /var/lib/bind/zones/db.learn-it.local
     ```

   - Vous devriez voir une entrée pour `client`.

5. **Vérifier les logs pour les mises à jour DNS**

   - Consultez les logs de BIND pour voir les mises à jour dynamiques :

     ```bash
     sudo journalctl -u bind9
     ```

   - Recherchez des messages indiquant que des mises à jour ont été reçues du serveur DHCP-DDNS.

## **Notes importantes**

- **Sécurité des clés TSIG**

  - Les clés TSIG doivent être protégées. Ne partagez pas les clés secrètes et limitez les permissions des fichiers de clé.

- **Permissions des fichiers de zone**

  - Assurez-vous que l'utilisateur `bind` a les permissions d'écriture sur les fichiers de zone pour permettre les mises à jour dynamiques.

    ```bash
    sudo chown bind:bind /var/lib/bind/zones/db.learn-it.local
    sudo chown bind:bind /var/lib/bind/zones/db.192.168.200
    ```

- **Synchronisation de l'horloge système**

  - Les horloges des serveurs doivent être synchronisées (par exemple, en utilisant NTP) pour éviter des problèmes d'authentification avec TSIG. (ici, nous travaillons sur la même machine, il ne devrait pas y avoir de problème)

## **Comprendre l'utilisation des logs avec `journalctl`**

- **Consulter les logs de Kea DHCP4 :**

  ```bash
  sudo journalctl -u kea-dhcp4-server
  ```

- **Consulter les logs de Kea DHCP-DDNS :**

  ```bash
  sudo journalctl -u kea-dhcp-ddns-server
  ```

- **Consulter les logs de BIND :**

  ```bash
  sudo journalctl -u bind9
  ```

- **Suivre les logs en temps réel :**

  ```bash
  sudo journalctl -f -u kea-dhcp4-server
  sudo journalctl -f -u kea-dhcp-ddns-server
  sudo journalctl -f -u bind9
  ```

- **Analyse des logs :**

  - Recherchez les messages d'erreur ou les avertissements.
  - Vérifiez que les mises à jour DNS sont correctement envoyées et traitées.
  - Utilisez les logs pour diagnostiquer et résoudre les problèmes éventuels.

## **Conclusion**

En suivant ces étapes, vous avez configuré **Kea DHCP** sur **server1** pour fournir des adresses IP dynamiquement aux clients de votre réseau. Vous avez également mis en place les mises à jour DNS dynamiques (DDNS), ce qui permet d'automatiser l'enregistrement des noms de machines dans le serveur DNS.

Cette configuration assure que les enregistrements DNS sont toujours à jour avec les adresses IP attribuées, facilitant la gestion du réseau et améliorant la fiabilité de la résolution des noms.

---

**Récapitulatif des étapes :**

1. **Comprendre le fonctionnement du protocole DHCP** (client/serveur).
2. **Installer Kea DHCP** et le serveur DHCP-DDNS.
3. **Générer une clé TSIG** pour sécuriser les mises à jour DNS.
4. **Configurer Kea DHCP** dans `/etc/kea/kea-dhcp4.conf` avec des commentaires explicatifs.
5. **Configurer Kea DHCP-DDNS** dans `/etc/kea/kea-dhcp-ddns.conf` avec des commentaires.
6. **Configurer BIND** pour accepter les mises à jour dynamiques sécurisées avec TSIG.
7. **Démarrer les services** Kea DHCP et DHCP-DDNS.
8. **Tester le fonctionnement** en attribuant une adresse IP à un client et en vérifiant les mises à jour DNS.
9. **Utiliser `journalctl`** pour surveiller les logs et diagnostiquer les problèmes.

---

**Prochaines étapes :**

- **Surveiller les services** pour s'assurer qu'ils fonctionnent correctement sur la durée.
- **Tester avec plusieurs clients** pour vérifier la robustesse de la configuration.
- **Explorer les fonctionnalités avancées de Kea**, comme les réservations d'adresses, les options spécifiques aux clients, ou l'intégration avec une base de données pour les baux DHCP.
- **Assurer la sécurité du réseau** en mettant en place des mesures supplémentaires, comme des pare-feu ou des contrôles d'accès.

---

**Remarques finales :**

- **Documenter votre configuration** pour faciliter la maintenance future.
- **Rester vigilant sur les mises à jour de sécurité** pour Kea, BIND et le système d'exploitation.
- **Continuer à approfondir vos connaissances** sur les services réseau pour améliorer et optimiser votre infrastructure.

---

**Félicitations pour avoir mis en place un service DHCP avancé avec des mises à jour DNS dynamiques !**
