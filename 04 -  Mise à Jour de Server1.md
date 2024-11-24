## **Étape 4 : Mise à Jour de Server1**

### **Vérifier et Configurer le Fichier `sources.list`**

1. **Comprendre l'importance du fichier `sources.list`** :

   - Le fichier `/etc/apt/sources.list` contient la liste des dépôts de paquets.
   - Une mauvaise configuration peut entraîner des problèmes de sécurité ou des dysfonctionnements du système.
   - **Sécurité** : Ne jamais ajouter de dépôts non officiels ou non fiables.

2. **Vérifier le contenu du fichier** :

   ```bash
   cat /etc/apt/sources.list
   ```

   Le contenu devrait ressembler à ceci :

   ```
   deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
   deb-src http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware

   deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
   deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware

   deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
   deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
   ```

3. **Modifier le fichier si nécessaire** :

   - Éditez le fichier avec :

     ```bash
     sudo nano /etc/apt/sources.list
     ```

   - Assurez-vous que les dépôts pointent vers `bookworm` (Debian 12) et incluent les sections `main`, `contrib`, `non-free`, et `non-free-firmware` si nécessaire.

### **Mettre à Jour le Système**

1. **Mettre à jour la liste des paquets** :

   ```bash
   sudo apt update
   ```

2. **Mettre à niveau les paquets installés** :

   ```bash
   sudo apt full-upgrade
   ```

3. **Utiliser `journalctl` pour vérifier les logs de mise à jour** :

   ```bash
   sudo journalctl -u apt-daily.service
   ```

---
