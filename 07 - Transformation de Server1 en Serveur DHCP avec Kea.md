# **Étape 7 : Transformation de server1 en serveur DHCP avec Kea et Mise en Place du DDNS**

Dans cette étape, nous allons transformer **server1** en serveur DHCP en utilisant **Kea**, et mettre en place les mises à jour DNS dynamiques (DDNS) afin que les baux DHCP soient automatiquement enregistrés dans notre serveur DNS. Nous utiliserons les fichiers de configuration fournis, et la clé TSIG générée lors de l'installation de **Bind9** (située dans `/etc/bind/rndc.key`).

## **Comprendre le Fonctionnement du Protocole DHCP**

### **Qu'est-ce que le DHCP ?**

Le **DHCP** (Dynamic Host Configuration Protocol) est un protocole réseau qui permet aux clients d'obtenir automatiquement les paramètres de configuration IP nécessaires pour communiquer sur un réseau. Ces paramètres incluent :

- **Adresse IP**
- **Masque de sous-réseau**
- **Passerelle par défaut**
- **Serveurs DNS**
- **Autres options spécifiques**

### **Fonctionnement du DHCP : Interaction Client/Serveur**

Le processus DHCP suit une séquence d'échanges entre le client et le serveur, souvent décrite par l'acronyme **DORA** :

1. **Discovery (Découverte)** : Le client envoie un message **DHCPDISCOVER** en broadcast pour localiser les serveurs DHCP disponibles sur le réseau.
2. **Offer (Offre)** : Les serveurs DHCP répondent avec un message **DHCPOFFER**, proposant une configuration IP au client.
3. **Request (Demande)** : Le client choisit une offre et envoie un message **DHCPREQUEST** pour demander la configuration proposée.
4. **Acknowledgment (Accusé de réception)** : Le serveur confirme la configuration avec un message **DHCPACK**, finalisant le processus.

**Schéma du processus DORA :**

```ini
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

### **Rôles du Serveur et du Client DHCP**

- **Serveur DHCP :**

  - Gère un pool d'adresses IP disponibles pour les clients.
  - Alloue des adresses IP aux clients selon des politiques définies.
  - Fournit des informations de configuration supplémentaires (passerelle, DNS, etc.).
  - Gère la durée des baux (leases) et le renouvellement des adresses IP.

- **Client DHCP :**

  - Demande une configuration réseau au serveur DHCP.
  - Renouvelle son bail périodiquement avant expiration.
  - Libère l'adresse IP lorsqu'il n'en a plus besoin (par exemple, à l'extinction).

## **Installer et Configurer Kea DHCP et Kea DHCP-DDNS**

### **1. Installer Kea DHCP**

Installez les paquets nécessaires :

```bash
sudo apt install kea-dhcp4-server kea-dhcp-ddns-server
```

- **`kea-dhcp4-server`** : Serveur DHCP pour IPv4.
- **`kea-dhcp-ddns-server`** : Serveur Kea pour les mises à jour DNS dynamiques (DDNS).

### **2. Configurer Kea DHCP**

#### **Fichier de Configuration du Serveur DHCP : `/etc/kea/kea-dhcp4.conf`**

Voici le contenu du fichier de configuration, avec des commentaires expliquant chaque section :

```jsonc
{
    "Dhcp4": {
        "interfaces-config": {
            // On configure ici notre interface d'écoute sur la couche 2
            "interfaces": [
                "eth1"
            ]
        },
        // On indique que l'on souhaite stocker la bdd des baux en fichier
        "lease-database": {
            "type": "memfile",
            "lfc-interval": 3600
        },
        "renew-timer": 900,
        "rebind-timer": 1800,
        "valid-lifetime": 3600,
        // Important, permet d'indiquer qu'il faut communiquer avec le service  kea-dhcp-ddns-server
        "dhcp-ddns": {
            "enable-updates": true
        },
        // On indique le suffixe DNS de notre zone locale
        "ddns-qualifying-suffix": "learn-it.local",
        "ddns-override-client-update": true,
        // Il s'agit des options passées aux clients DHCP
        "option-data": [
            {
                // On indique le serveur DNS à utiliser
                "name": "domain-name-servers",
                "data": "192.168.200.254"
            },
            {
                // On indique le suffixe DNS à utiliser
                "name": "domain-name",
                "data": "learn-it.local"
            },
            {
                // On indique le suffixe DNS à utiliser
                "name": "domain-search",
                "data": "learn-it.local"
            }
        ],
        // On définit ici nos sous réseaux, nous n'en avons qu'un seul dans le cadre du TP
        "subnet4": [
            {
                "subnet": "192.168.200.0/24",
                // Dans ce réseau, nous définissons nos plages d'IP a allouer aux clients
                "pools": [
                    {
                        // Nous n'en avons qu'une seule dans le cadre du TP
                        "pool": "192.168.200.100 - 192.168.200.110"
                    }
                ],
                "option-data": [
                    {
                        // On indique la passerelle (routeur par défaut) que les clients devront utiliser
                        "name": "routers",
                        "data": "192.168.200.254"
                    }
                ],
                "reservations": []
            }
        ],
        "loggers": [
            {
                "name": "kea-dhcp4",
                "output_options": [
                    {
                        "output": "syslog",
                        "pattern": "%-5p %m\n"
                    }
                ],
                "severity": "INFO",
                "debuglevel": 99
            }
        ]
    }
}
```

**Explications :**

- **`interfaces-config`** : Spécifie l'interface réseau sur laquelle le serveur DHCP écoute. Remplacez `"enp0s8"` par le nom de votre interface interne.
- **`lease-database`** : Configure la base de données des baux. Ici, nous utilisons un fichier en mémoire (`memfile`) avec un intervalle de nettoyage de 3600 secondes.
- **`renew-timer`, `rebind-timer`, `valid-lifetime`** : Définissent les temporisateurs pour le renouvellement des baux DHCP.
- **`dhcp-ddns`** : Active la communication avec le service `kea-dhcp-ddns-server` pour les mises à jour DNS dynamiques.
- **`ddns-qualifying-suffix`** : Spécifie le suffixe DNS pour les mises à jour.
- **`option-data`** : Définit les options DHCP à fournir aux clients, comme les serveurs DNS et le domaine.
- **`subnet4`** : Définit le sous-réseau géré, les plages d'adresses IP, les options spécifiques (comme la passerelle), et les réservations (ici vide).
- **`loggers`** : Configure la journalisation pour faciliter le dépannage.

#### **Fichier de Configuration du Serveur DHCP-DDNS : `/etc/kea/kea-dhcp-ddns.conf`**

Voici le contenu du fichier de configuration du service DHCP-DDNS :

```jsonc
{
  "DhcpDdns": {
    // Définition de la clé TSIG partagée avec le serveur DNS
    
    "tsig-keys": [
      {
        "name": "rndc-key",
        "algorithm": "HMAC-SHA256",
        "secret": "VOTRE_CLE_RNDC_ICI"
      }
    ],
    // Définition des zones DNS à mettre à jour
    // Zone directe
    "forward-ddns": {
      "ddns-domains": [
        {
          "name": "learn-it.local.",
          "key-name": "rndc-key",
          // Liste des serveurs DNS à mettre à jour
          "dns-servers": [
            {
              "ip-address": "127.0.0.1"
            }
          ]
        }
      ]
    },
    // Zone inverse
    "reverse-ddns": {
      "ddns-domains": [
        {
          "name": "200.168.192.in-addr.arpa.",
          "key-name": "rndc-key",
          "dns-servers": [
            {
              "ip-address": "127.0.0.1"
            }
          ]
        }
      ]
    }
  }
}
```

**Explications :**

- **`tsig-keys`** : Définit les clés TSIG utilisées pour sécuriser les mises à jour DNS. Nous utiliserons la clé existante `rndc-key` générée par **Bind9**.
- **`forward-ddns`** : Configure les mises à jour DNS pour les enregistrements de type A (résolution directe) pour le domaine `learn-it.local`.
- **`reverse-ddns`** : Configure les mises à jour DNS pour les enregistrements de type PTR (résolution inverse) pour la zone `200.168.192.in-addr.arpa`.

### **3. Utiliser la Clé TSIG Générée par Bind9**

Lors de l'installation de **Bind9**, une clé TSIG est générée automatiquement et stockée dans `/etc/bind/rndc.key`. Nous allons utiliser cette clé pour sécuriser les communications entre Kea et Bind9.

#### **Extraire la Clé TSIG**

1. **Afficher le contenu de `/etc/bind/rndc.key`** :

   ```bash
   sudo cat /etc/bind/rndc.key
   ```

2. **Copier le nom de la clé, l'algorithme et le secret**.

   Exemple de contenu :

   ```bind
   key "rndc-key" {
       algorithm hmac-sha256;
       secret "W1aFxOn2j0mDDBmENR8ppxKL/OaSx5BOAFI4W2t7MLI=";
   };
   ```

#### **Configurer Kea DHCP-DDNS avec la Clé TSIG**

- Dans le fichier `/etc/kea/kea-dhcp-ddns.conf`, remplacez `"VOTRE_CLÉ_SECRÈTE_IÇI"` par le secret extrait de `/etc/bind/rndc.key`.
- Assurez-vous que le nom de la clé (`"rndc-key"`) et l'algorithme (`"HMAC-SHA256"`) correspondent.

### **4. Configurer Bind9 pour Accepter les Mises à Jour Dynamiques**

Nous devons configurer **Bind9** pour accepter les mises à jour DNS dynamiques sécurisées avec la clé TSIG.

#### **Éditer le Fichier `/etc/bind/named.conf.local`**

Ajoutez la configuration pour la clé TSIG et mettez à jour les zones :

```bind
include "/etc/bind/rndc.key";

zone "learn-it.local" IN {
    type master;
    file "/var/lib/bind/zones/db.learn-it.local";
    // Autoriser les mises à jour dynamiques sécurisées
    allow-update { key rndc-key; };
};

zone "200.168.192.in-addr.arpa" IN {
    type master;
    file "/var/lib/bind/zones/db.192.168.200";
    // Autoriser les mises à jour dynamiques sécurisées
    allow-update { key rndc-key; };
};
```

**Explications :**

- **`include "/etc/bind/rndc.key";`** : Inclut le fichier contenant la clé TSIG.
- **`allow-update`** : Autorise les mises à jour dynamiques pour les zones spécifiées, en utilisant la clé `rndc-key`.

#### **Vérifier les Permissions**

Assurez-vous que l'utilisateur `bind` a les permissions nécessaires sur les fichiers de zone pour permettre les mises à jour dynamiques :

```bash
sudo chown -R bind:bind /var/lib/bind
```

#### **Redémarrer Bind9**

```bash
sudo systemctl restart bind9
```

### **5. Démarrer et Activer les Services Kea**

#### **Démarrer le Serveur DHCP-DDNS**

```bash
sudo systemctl enable kea-dhcp-ddns-server
sudo systemctl start kea-dhcp-ddns-server
```

#### **Démarrer le Serveur DHCP4**

```bash
sudo systemctl enable kea-dhcp4-server
sudo systemctl start kea-dhcp4-server
```

### **6. Vérifier les Configurations et les Logs**

- **Vérifier les logs de Kea DHCP4** :

  ```bash
  sudo journalctl -u kea-dhcp4-server
  ```

- **Vérifier les logs de Kea DHCP-DDNS** :

  ```bash
  sudo journalctl -u kea-dhcp-ddns-server
  ```

- **Vérifier les logs de Bind9** :

  ```bash
  sudo journalctl -u bind9
  ```

- **Analyser les logs pour détecter d'éventuelles erreurs ou problèmes de communication.**

## **Tester le Fonctionnement du DHCP avec Mises à Jour DNS Dynamiques**

1. **Configurer le Client Windows pour Obtenir une IP Automatiquement**

   - Dans les paramètres réseau du client Windows, assurez-vous que l'option **"Obtenir une adresse IP automatiquement"** est sélectionnée.

2. **Vérifier que le Client Obtient une Adresse IP**

   - Ouvrez une invite de commandes sur le client Windows et exécutez :

     ```cmd
     ipconfig /all
     ```

   - Vérifiez que l'adresse IP attribuée est dans la plage `192.168.200.100 - 192.168.200.110`.

3. **Tester la Connectivité et la Résolution DNS**

   - **Depuis le client Windows** :

     - Pinger le serveur DNS :

       ```cmd
       ping server1.learn-it.local
       ```

     - Vérifier la résolution DNS :

       ```cmd
       nslookup server1.learn-it.local
       ```

   - **Depuis server1** :

     - Vérifier que le nom du client est enregistré dans le DNS :

       ```bash
       dig client.learn-it.local
       ```

     - Vérifier la résolution inverse :

       ```bash
       dig -x [adresse IP du client]
       ```

4. **Vérifier les Enregistrements DNS sur le Serveur**

   - Les mises à jour dynamiques modifient les fichiers de zone. Vous pouvez consulter le fichier de zone pour vérifier que l'enregistrement a été ajouté.

     ```bash
     sudo cat /var/lib/bind/zones/db.learn-it.local
     ```

   - Vous devriez voir une entrée pour le nom d'hôte du client.

5. **Vérifier les Logs pour les Mises à Jour DNS**

   - Consultez les logs de **Bind9** pour voir les mises à jour dynamiques :

     ```bash
     sudo journalctl -u bind9
     ```

   - Recherchez des messages indiquant que des mises à jour ont été reçues du serveur DHCP-DDNS.

## **Notes Importantes**

- **Sécurité des Clés TSIG**

  - Les clés TSIG doivent être protégées. Ne partagez pas les clés secrètes et limitez les permissions des fichiers de clé.
  - Le fichier `/etc/bind/rndc.key` est généralement protégé avec les permissions appropriées.

- **Permissions des Fichiers de Zone**

  - Assurez-vous que l'utilisateur `bind` a les permissions d'écriture sur les fichiers de zone pour permettre les mises à jour dynamiques.

- **Synchronisation de l'Horloge Système**

  - Les horloges des serveurs doivent être synchronisées (par exemple, en utilisant NTP) pour éviter des problèmes d'authentification avec TSIG.

- **Validation des Configurations**

  - Utilisez les commandes de vérification de configuration pour **Bind9** :

    ```bash
    sudo named-checkconf
    sudo named-checkzone learn-it.local /var/lib/bind/zones/db.learn-it.local
    ```

## **Comprendre l'Utilisation des Logs avec `journalctl`**

- **Consulter les logs de Kea DHCP4** :

  ```bash
  sudo journalctl -u kea-dhcp4-server
  ```

- **Consulter les logs de Kea DHCP-DDNS** :

  ```bash
  sudo journalctl -u kea-dhcp-ddns-server
  ```

- **Consulter les logs de Bind9** :

  ```bash
  sudo journalctl -u bind9
  ```

- **Suivre les logs en temps réel** :

  ```bash
  sudo journalctl -f -u kea-dhcp4-server
  sudo journalctl -f -u kea-dhcp-ddns-server
  sudo journalctl -f -u bind9
  ```

- **Analyse des logs** :

  - Recherchez les messages d'erreur ou les avertissements.
  - Vérifiez que les mises à jour DNS sont correctement envoyées et traitées.
  - Utilisez les logs pour diagnostiquer et résoudre les problèmes éventuels.

## **Conclusion**

En suivant ces étapes, vous avez configuré **Kea DHCP** sur **server1** pour fournir des adresses IP dynamiquement aux clients de votre réseau, et mis en place les mises à jour DNS dynamiques (DDNS) sécurisées avec TSIG. Cela permet d'automatiser l'enregistrement des noms de machines dans le serveur DNS, assurant que les enregistrements DNS sont toujours à jour avec les adresses IP attribuées.

---

**Récapitulatif des Étapes :**

1. **Installer Kea DHCP et Kea DHCP-DDNS**.
2. **Configurer Kea DHCP** en utilisant le fichier `/etc/kea/kea-dhcp4.conf` fourni, avec les commentaires explicatifs.
3. **Configurer Kea DHCP-DDNS** en utilisant le fichier `/etc/kea/kea-dhcp-ddns.conf` fourni, en utilisant la clé TSIG générée par **Bind9**.
4. **Configurer Bind9** pour accepter les mises à jour dynamiques sécurisées en incluant le fichier `/etc/bind/rndc.key` et en ajustant les zones.
5. **Démarrer et activer les services Kea DHCP et Kea DHCP-DDNS**.
6. **Vérifier les configurations et les logs** pour s'assurer que tout fonctionne correctement.
7. **Tester le fonctionnement** en attribuant une adresse IP à un client et en vérifiant les mises à jour DNS.

---

**Prochaines Étapes :**

- **Surveiller les services** pour s'assurer qu'ils fonctionnent correctement sur la durée.
- **Tester avec plusieurs clients** pour vérifier la robustesse de la configuration.
- **Continuer à approfondir vos connaissances** sur les services réseau pour améliorer et optimiser votre infrastructure.

---

**Félicitations pour avoir mis en place un service DHCP avancé avec des mises à jour DNS dynamiques sécurisées !**

---

**Remarques Finales :**

- **Documentez vos configurations** pour faciliter la maintenance future.
- **Assurez-vous que les services démarrent automatiquement** au démarrage du système.
- **Restez vigilant sur les mises à jour de sécurité** pour **Kea**, **Bind9** et le système d'exploitation.

---

**Bon travail et bonne continuation dans votre apprentissage de l'administration système !**
