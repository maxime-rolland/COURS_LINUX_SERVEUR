## **Étape 2 : Configuration des Interfaces Réseau**

### **Configuration Réseau de Server1**

1. **Lister les interfaces réseau disponibles** :

   ```bash
   ip addr show
   ```

   Vous devriez voir au moins deux interfaces, par exemple `enp0s3` (NAT) et `enp0s8` (intnet).

2. **Configurer l'interface NAT (Interface 1)** :

   - Éditez le fichier `/etc/network/interfaces` :

     ```bash
     sudo nano /etc/network/interfaces
     ```

     Ajoutez ou modifiez les lignes pour l'interface NAT :

     ```
     auto enp0s3
     iface enp0s3 inet dhcp
     ```

     _Assurez-vous que l'interface NAT est configurée pour démarrer automatiquement (`auto`), sinon elle sera inactive après un redémarrage du service réseau._

3. **Configurer l'interface interne (Interface 2)** :

   Ajoutez les lignes suivantes pour l'interface interne :

   ```
   auto enp0s8
   iface enp0s8 inet static
       address 192.168.200.254
       netmask 255.255.255.0
   ```

4. **Redémarrer le service réseau** :

   ```bash
   sudo systemctl restart networking
   ```

5. **Vérifier la configuration des interfaces** :

   ```bash
   ip addr show enp0s3
   ip addr show enp0s8
   ```

6. **Vérifier l'accès à Internet** :

   ```bash
   ping -c 4 google.com
   ```

### **Configuration Réseau de Server2**

1. **Lister les interfaces réseau disponibles** :

   ```bash
   ip addr show
   ```

   Vous devriez voir l'interface `enp0s3` (intnet).

2. **Configurer l'interface interne avec une IP statique** :

   - Éditez le fichier `/etc/network/interfaces` :

     ```bash
     sudo nano /etc/network/interfaces
     ```

     Ajoutez les lignes suivantes :

     ```
     auto enp0s3
     iface enp0s3 inet static
         address 192.168.200.2
         netmask 255.255.255.0
         gateway 192.168.200.254
     ```

3. **Redémarrer le service réseau** :

   ```bash
   sudo systemctl restart networking
   ```

4. **Vérifier la configuration** :

   ```bash
   ip addr show enp0s3
   ```

5. **Tester la connectivité avec Server1** :

   ```bash
   ping -c 4 192.168.200.254
   ```

### **Configuration Réseau du Client Windows**

1. **Configurer l'interface réseau** :

   - Accédez aux paramètres de votre carte réseau.
   - Modifiez les propriétés de **Protocole Internet version 4 (TCP/IPv4)**.
   - Entrez les informations suivantes :

     - **Adresse IP** : `192.168.200.1`
     - **Masque de sous-réseau** : `255.255.255.0`
     - **Passerelle par défaut** : `192.168.200.254`
     - **Serveur DNS préféré** : `192.168.200.254`

2. **Tester la connectivité avec les serveurs** :

   - Ouvrez l'invite de commandes :

     ```cmd
     ping 192.168.200.254
     ping 192.168.200.2
     ```

   Si les pings réussissent, la connectivité est en place.

---
