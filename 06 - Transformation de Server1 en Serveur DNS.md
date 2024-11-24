## **Étape 6 : Transformation de Server1 en Serveur DNS**

### **Installer et Configurer Bind9**

1. **Installer Bind9** :

   ```bash
   sudo apt install bind9 bind9utils bind9-doc
   ```

2. **Créer le Répertoire pour les Fichiers de Zone** :

   ```bash
   sudo mkdir -p /var/lib/bind/zones
   sudo chown -R bind:bind /var/lib/bind/zones
   ```

3. **Configurer Bind9** :

   - Éditez le fichier `/etc/bind/named.conf.local` :

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

### **Créer les Fichiers de Zone (Directe et Inverse)**

1. **Zone de Recherche Directe** :

   - Créez le fichier `/var/lib/bind/zones/db.learn-it.local` :

     ```bash
     sudo nano /var/lib/bind/zones/db.learn-it.local
     ```

     Contenu du fichier :

     ```
     $TTL    604800
     @       IN      SOA     server1.learn-it.local. admin.learn-it.local. (
                               3         ; Serial
                               604800    ; Refresh
                               86400     ; Retry
                               2419200   ; Expire
                               604800 )  ; Negative Cache TTL
     ;
     @       IN      NS      server1.learn-it.local.
     server1 IN      A       192.168.200.254
     server2 IN      A       192.168.200.2
     client  IN      A       192.168.200.1
     site1   IN      A       192.168.200.2
     site2   IN      A       192.168.200.2
     site3   IN      A       192.168.200.2
     glpi    IN      A       192.168.200.2
     ```

2. **Zone de Recherche Inverse** :

   - Créez le fichier `/var/lib/bind/zones/db.192.168.200` :

     ```bash
     sudo nano /var/lib/bind/zones/db.192.168.200
     ```

     Contenu du fichier :

     ```
     $TTL    604800
     @       IN      SOA     server1.learn-it.local. admin.learn-it.local. (
                               3         ; Serial
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

### **Configurer les Permissions Appropriées**

- Assurez-vous que les fichiers de zone appartiennent à l'utilisateur `bind` :

  ```bash
  sudo chown bind:bind /var/lib/bind/zones/db.learn-it.local
  sudo chown bind:bind /var/lib/bind/zones/db.192.168.200
  ```

### **Tester la Résolution DNS**

1. **Vérifier la configuration de Bind9** :

   ```bash
   sudo named-checkconf
   sudo named-checkzone learn-it.local /var/lib/bind/zones/db.learn-it.local
   sudo named-checkzone 200.168.192.in-addr.arpa /var/lib/bind/zones/db.192.168.200
   ```

2. **Redémarrer Bind9** :

   ```bash
   sudo systemctl restart bind9
   ```

3. **Tester depuis Server1 ou Server2** :

   ```bash
   dig @localhost server1.learn-it.local
   dig @localhost -x 192.168.200.254
   ```

4. **Tester depuis le Client Windows** :

   - Assurez-vous que le serveur DNS est bien configuré (192.168.200.254).
   - Utilisez la commande :

     ```cmd
     nslookup server1.learn-it.local
     ```

---
