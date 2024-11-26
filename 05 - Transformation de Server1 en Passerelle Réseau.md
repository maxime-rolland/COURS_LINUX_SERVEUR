## **Étape 5 : Transformation de Server1 en Passerelle Réseau**

### **Comprendre le Routage, les Passerelles, et l'Intérêt du NAT/PAT (Masquerade)**

- **Routage** : Le routage est le processus qui permet de transférer des paquets de données d'un réseau à un autre. Un routeur utilise des tables de routage pour déterminer le meilleur chemin vers la destination.

- **Passerelle (Gateway)** : Une passerelle est un point d'accès qui connecte un réseau local à un autre réseau, souvent Internet. Elle agit comme une porte d'entrée et de sortie pour le trafic réseau.

- **NAT (Network Address Translation)** : Le NAT est une technique qui traduit les adresses IP privées d'un réseau local en une adresse IP publique unique. Cela permet de masquer les adresses IP internes et de partager une seule adresse IP publique pour l'accès à Internet.

- **PAT (Port Address Translation)** : Le PAT est une extension du NAT qui, en plus de traduire les adresses IP, traduit également les numéros de port. Cela permet à plusieurs appareils d'utiliser simultanément une seule adresse IP publique.

- **Masquerade** : Dans le contexte de **nftables**, la cible `masquerade` est utilisée pour effectuer du NAT dynamique, en remplaçant l'adresse IP source des paquets sortants par l'adresse IP de l'interface de sortie. Cela permet aux appareils du réseau local d'accéder à Internet en utilisant l'adresse IP publique de la passerelle.

### **Comprendre nftables (Framework NetFilter)**

- **nftables** est un framework qui remplace **iptables** pour la configuration du pare-feu du noyau Linux. Il offre une syntaxe unifiée pour le filtrage des paquets, le NAT, et d'autres fonctionnalités de sécurité réseau.

- **Avantages de nftables** :

  - Syntaxe simplifiée et cohérente.
  - Meilleures performances.
  - Gestion plus flexible et modulaire des règles.

### **Activer le Routage IP**

1. **Modifier le fichier `/etc/sysctl.conf`** :

   ```bash
   sudo nano /etc/sysctl.conf
   ```

   Décommentez ou ajoutez la ligne :

   ```
   net.ipv4.ip_forward=1
   ```

2. **Appliquer les changements immédiatement** :

   ```bash
   sudo sysctl -p
   ```

### **Configurer nftables Étape par Étape pour le NAT**

1. **Installer nftables** :

   ```bash
   sudo apt install nftables
   ```

2. **Vider les règles existantes** :

   ```bash
   sudo nft flush ruleset
   ```

3. **Créer une nouvelle table pour le NAT** :

   ```bash
   sudo nft add table ip nat
   ```

4. **Créer une chaîne `prerouting` pour le NAT** :

   ```bash
   sudo nft 'add chain ip nat prerouting { type nat hook prerouting priority -100; policy accept; }'
   ```

   **Explication** :

   - La chaîne `prerouting` est utilisée pour modifier les paquets entrants avant le routage. Bien que nous n'ajoutions pas de règles spécifiques ici, elle est nécessaire pour une configuration complète du NAT.

5. **Créer une chaîne `postrouting` pour le NAT** :

   ```bash
   sudo nft 'add chain ip nat postrouting { type nat hook postrouting priority 100; policy accept; }'
   ```

   **Explication** :

   - La chaîne `postrouting` est utilisée pour modifier les paquets sortants après le routage. Nous y ajouterons notre règle de masquerade.

6. **Ajouter la règle de masquerade** :

   - Identifiez le nom de votre interface NAT (par exemple, `enp0s3`).

   - Ajoutez la règle :

     ```bash
     sudo nft add rule ip nat postrouting oifname "enp0s3" masquerade
     ```

   **Explication** :

   - **oifname "enp0s3"** : La règle s'applique aux paquets sortant par l'interface `enp0s3` (interface connectée à Internet).
   - **masquerade** : Remplace l'adresse IP source des paquets par l'adresse IP de l'interface de sortie, permettant le NAT/PAT.

   _Remarque :_ Nous ciblons l'interface pour nous assurer que la règle de masquerade ne s'applique qu'aux paquets sortants vers Internet, évitant ainsi des problèmes de routage sur le réseau interne.

7. **Vérifier les règles nftables** :

   ```bash
   sudo nft list ruleset
   ```

8. **Sauvegarder la configuration** :

   - Redirigez la sortie de la commande précédente vers le fichier `/etc/nftables.conf` en utilisant `tee` :

     ```bash
     sudo nft list ruleset | sudo tee /etc/nftables.conf
     ```

   **Explication** :

   - Le fichier `/etc/nftables.conf` est chargé au démarrage. En y enregistrant les règles actuelles, vous assurez la persistance des règles après un redémarrage.

9. **Activer et démarrer nftables** :

   ```bash
   sudo systemctl enable nftables
   sudo systemctl start nftables
   ```

### **Tester l'Accès Internet depuis le Réseau Interne**

- **Sur Server2** :

  ```bash
  ping -c 4 8.8.8.8
  ```

- **Sur le Client Windows** :

  - Ouvrez un navigateur web et accédez à `http://www.google.com`.
  - Si l'accès fonctionne, la passerelle est correctement configurée.

---
