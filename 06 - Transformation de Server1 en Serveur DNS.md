# **Étape 6 : Transformation de server1 en serveur DNS**

Dans cette étape, nous allons transformer **server1** en serveur DNS pour notre réseau interne. Nous utiliserons des enregistrements **CNAME** pour les alias `site1`, `site2`, `site3` et `glpi`, pointant tous vers `server2.learn-it.local`.

## **Introduction au DNS**

### **Qu'est-ce que le DNS ?**

Le **DNS** (Domain Name System) est un système qui permet de traduire les noms de domaine lisibles par les humains (comme `www.example.com`) en adresses IP compréhensibles par les machines (comme `192.0.2.1`). Il agit comme un annuaire téléphonique pour Internet, permettant aux utilisateurs d'accéder aux ressources réseau en utilisant des noms faciles à retenir.

### **Rôle du serveur DNS**

Le serveur DNS est responsable de la résolution des noms de domaine en adresses IP. Il contient des enregistrements DNS qui associent des noms de domaine à des adresses IP ou à d'autres noms de domaine.

### **Rôle du client DNS**

Le client DNS est généralement une machine ou un logiciel qui a besoin de traduire un nom de domaine en adresse IP pour établir une connexion réseau. Le client envoie une requête DNS au serveur DNS configuré, attend la réponse, puis utilise l'adresse IP retournée pour communiquer avec la ressource désirée.

### **Principe de résolution DNS**

Le processus de résolution DNS suit généralement ces étapes :

1. **Vérification du fichier hosts local**
2. **Vérification du cache DNS**
3. **Interrogation du serveur DNS configuré**
4. **Résolution récursive ou itérative**
5. **Mise en cache des résultats**

### **Utilisation des enregistrements CNAME**

Un enregistrement **CNAME** (Canonical Name) est un type d'enregistrement DNS qui permet de faire un alias d'un nom de domaine vers un autre nom de domaine. Cela est utile lorsque plusieurs noms de domaine doivent pointer vers la même ressource, sans avoir à gérer plusieurs enregistrements A avec la même adresse IP.

**Avantages des CNAME :**

- **Gestion simplifiée** : Si l'adresse IP de la ressource change, il suffit de mettre à jour un seul enregistrement A.
- **Flexibilité** : Permet de créer des alias pour des services hébergés sur le même serveur.

## **Installation et configuration de Bind9**

### **1. Installer Bind9**

Sur **server1**, installez les paquets nécessaires :

```bash
sudo apt install bind9 bind9utils bind9-doc
```

### **2. Créer le répertoire pour les fichiers de zone**

Créez le répertoire et ajustez les permissions :

```bash
sudo mkdir -p /var/lib/bind/zones
sudo chown -R bind:bind /var/lib/bind/zones
```

### **3. Configurer Bind9**

Éditez le fichier de configuration local de Bind9 :

```bash
sudo nano /etc/bind/named.conf.local
```

Ajoutez les zones suivantes :

```bind
zone "learn-it.local" IN {
    type master;
    file "/var/lib/bind/zones/db.learn-it.local";
};

zone "200.168.192.in-addr.arpa" IN {
    type master;
    file "/var/lib/bind/zones/db.192.168.200";
};
```

## **Création des fichiers de zone (Directe et Inverse)**

### **1. Zone de recherche directe**

Créez le fichier `/var/lib/bind/zones/db.learn-it.local` :

```bash
sudo nano /var/lib/bind/zones/db.learn-it.local
```

Contenu du fichier :

```ini
$TTL    604800
@       IN      SOA     server1.learn-it.local. admin.learn-it.local. (
                          4         ; Serial
                          604800    ; Refresh
                          86400     ; Retry
                          2419200   ; Expire
                          604800 )  ; Negative Cache TTL
;
@       IN      NS      server1.learn-it.local.
server1 IN      A       192.168.200.254
server2 IN      A       192.168.200.2
client  IN      A       192.168.200.1

; Utilisation de CNAME pour les sites web
site1   IN      CNAME   server2.learn-it.local.
site2   IN      CNAME   server2.learn-it.local.
site3   IN      CNAME   server2.learn-it.local.
glpi    IN      CNAME   server2.learn-it.local.
```

**Explication :**

- Les enregistrements **CNAME** pour `site1`, `site2`, `site3` et `glpi` pointent vers `server2.learn-it.local`.
- Si l'adresse IP de `server2.learn-it.local` change, il suffit de mettre à jour l'enregistrement A de `server2`, et tous les alias seront automatiquement mis à jour.

### **2. Zone de recherche inverse**

Créez le fichier `/var/lib/bind/zones/db.192.168.200` :

```bash
sudo nano /var/lib/bind/zones/db.192.168.200
```

Contenu du fichier :

```ini
$TTL    604800
@       IN      SOA     server1.learn-it.local. admin.learn-it.local. (
                          4         ; Serial
                          604800    ; Refresh
                          86400     ; Retry
                          2419200   ; Expire
                          604800 )  ; Negative Cache TTL
;
@       IN      NS      server1.learn-it.local.
254     IN      PTR     server1.learn-it.local.
2       IN      PTR     server2.learn-it.local.
1       IN      PTR     client.learn-it.local.
```

**Remarque :**

- Les enregistrements PTR sont associés aux adresses IP et pointent vers les noms canoniques (dans ce cas, `server1.learn-it.local`, `server2.learn-it.local`, etc.).

### **3. Configurer les permissions appropriées**

Assurez-vous que les fichiers de zone appartiennent à l'utilisateur `bind` :

```bash
sudo chown bind:bind /var/lib/bind/zones/db.learn-it.local
sudo chown bind:bind /var/lib/bind/zones/db.192.168.200
```

## **Tester la configuration du serveur DNS**

### **1. Vérifier la configuration de Bind9**

Vérifiez la syntaxe des fichiers de configuration :

```bash
sudo named-checkconf
sudo named-checkzone learn-it.local /var/lib/bind/zones/db.learn-it.local
sudo named-checkzone 200.168.192.in-addr.arpa /var/lib/bind/zones/db.192.168.200
```

### **2. Redémarrer Bind9**

Redémarrez le service Bind9 :

```bash
sudo systemctl restart bind9
```

### **3. Tester la résolution DNS sur le serveur**

Utilisez la commande `dig` pour tester la résolution :

```bash
dig @localhost site1.learn-it.local
dig @localhost site2.learn-it.local
dig @localhost glpi.learn-it.local
```

**Vérification des CNAME :**

Pour vérifier que les enregistrements CNAME fonctionnent correctement, vous pouvez utiliser l'option `-t CNAME` :

```bash
dig @localhost site1.learn-it.local -t CNAME
```

La réponse devrait indiquer que `site1.learn-it.local` est un alias pour `server2.learn-it.local`.

### **4. Tester depuis le client Windows**

Assurez-vous que le serveur DNS est bien configuré sur le client Windows (`192.168.200.254`).

Utilisez la commande `nslookup` :

```cmd
nslookup site1.learn-it.local
nslookup glpi.learn-it.local
```

Vous devriez voir que ces noms de domaine résolvent à l'adresse IP de `server2.learn-it.local` (`192.168.200.2`).

## **Avantages de l'utilisation des CNAME dans ce contexte**

- **Gestion centralisée** : En utilisant des CNAME, toute modification de l'adresse IP de `server2` n'exige qu'une seule mise à jour de l'enregistrement A de `server2.learn-it.local`.
- **Clarté** : Il est clair que `site1`, `site2`, `site3` et `glpi` sont tous hébergés sur `server2`.
- **Éviter la redondance** : Pas besoin de répéter la même adresse IP pour plusieurs enregistrements A.

## **Configurer le client DHCP pour utiliser le serveur DNS local**

La première carte réseau de server1 est configurée en DHCP et obtient sa configuration à partir du client DHCP. Le client DHCP va donc créer le fichier `/etc/resolv.conf` (permet la configuration du client DNS) à chaque redémarrage du service réseau. Il faut éditer le fichier de configuration du client dhcp `/etc/dhcp/dhclient.conf` et décommenter la ligne suivante :

```ini
prepend domain-name-servers 127.0.0.1;
```

## **Configurer le client DNS de server2 pour utiliser le serveur DNS server1

Le client DNS sous debian utilise le fichier de configuration `/etc/resolv.conf` (le créer s'il n'existe pas)

```bash
# Si l'utilitaire sudo est installé
echo "nameserver 192.168.200.254" | sudo tee /etc/resolv.conf"

# le cas échéant, passer en root et créer le fichier
su -
echo "nameserver 192.168.200.254" > /etc/resolv.conf
```

## **Conclusion**

En utilisant des enregistrements **CNAME** pour `site1`, `site2`, `site3` et `glpi`, nous avons simplifié la gestion de notre zone DNS. Cette approche offre une plus grande flexibilité et facilite la maintenance future, surtout si l'adresse IP du serveur hébergeant les sites web change.

---

**Note** : Lors de l'utilisation de CNAME, il est important de ne pas créer d'enregistrements supplémentaires (comme MX) pour les alias, car cela peut causer des problèmes de résolution. Dans notre cas, cela ne pose pas de problème car nous n'utilisons pas de tels enregistrements pour ces noms.

---

**Récapitulatif des étapes :**

1. **Installer Bind9** sur `server1`.
2. **Créer le répertoire** pour les fichiers de zone et ajuster les permissions.
3. **Configurer Bind9** en ajoutant les zones dans `named.conf.local`.
4. **Créer les fichiers de zone** :
   - Zone directe avec des enregistrements CNAME pour les sites web.
   - Zone inverse pour la résolution inverse.
5. **Vérifier la configuration** avec `named-checkconf` et `named-checkzone`.
6. **Redémarrer le service Bind9**.
7. **Tester la résolution DNS** depuis `server1`, `server2` et le client Windows.
8. **Comprendre les avantages** de l'utilisation des CNAME pour une gestion DNS simplifiée.

---

**Prochaines étapes :**

Continuez avec l'installation des services web sur `server2`, en vous assurant que les sites sont accessibles via les noms de domaine configurés (`site1.learn-it.local`, etc.). Vérifiez également que la résolution DNS fonctionne correctement pour tous les hôtes de votre réseau.

---
