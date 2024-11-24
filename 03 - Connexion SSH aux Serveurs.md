## **Étape 3 : Connexion SSH aux Serveurs**

### **Installer le Serveur SSH sur Server1 et Server2**

1. **Vérifier si OpenSSH est installé** :

   ```bash
   sudo apt install openssh-server
   ```

   Si le serveur SSH est déjà installé, le système vous le signalera.

2. **Vérifier le statut du service SSH** :

   ```bash
   sudo systemctl status ssh
   ```

   Le service doit être actif et en cours d'exécution.

### **Générer une Paire de Clés SSH sur le Client Windows**

1. **Ouvrir PowerShell** :

   - Appuyez sur **Windows + X** et sélectionnez **Windows PowerShell**.

2. **Générer la paire de clés** :

   ```powershell
   ssh-keygen -t rsa -b 2048
   ```

   - Acceptez l'emplacement par défaut (`C:\Users\VotreNom\.ssh\id_rsa`).
   - Choisissez une passphrase ou appuyez sur **Entrée** pour ne pas en mettre.

### **Configurer l'Authentification par Clé SSH sur les Serveurs**

1. **Copier la clé publique sur Server1** :

   - Si `ssh-copy-id` n'est pas disponible sur Windows, vous pouvez copier manuellement la clé publique.

   - Affichez le contenu de la clé publique :

     ```powershell
     type $env:USERPROFILE\.ssh\id_rsa.pub
     ```

   - Connectez-vous au serveur :

     ```powershell
     ssh user@192.168.200.254
     ```

   - Sur le serveur, créez le dossier `.ssh` et le fichier `authorized_keys` :

     ```bash
     mkdir -p ~/.ssh
     nano ~/.ssh/authorized_keys
     ```

   - Collez le contenu de votre clé publique dans ce fichier, enregistrez et quittez.

2. **Répéter les étapes pour Server2** (IP : `192.168.200.2`)

### **Se Connecter en SSH depuis le Client Windows**

- Vous pouvez maintenant vous connecter sans mot de passe :

  ```powershell
  ssh user@192.168.200.254
  ssh user@192.168.200.2
  ```

---
