## **Étape 7 : Transformation de Server1 en Serveur DHCP avec Kea**

### **Installer Kea DHCP**

```bash
sudo apt install kea-dhcp4-server
```

### **Configurer Kea pour Votre Réseau**

1. **Éditer le fichier de configuration** :

   ```bash
   sudo nano /etc/kea/kea-dhcp4.conf
   ```

2. **Configurer les paramètres suivants** :

   ```json
   {
     "Dhcp4": {
       "interfaces-config": {
         "interfaces": ["enp0s8"]
       },
       "lease-database": {
         "type": "memfile",
         "persist": true,
         "name": "/var/lib/kea/kea-leases4.csv"
       },
       "valid-lifetime": 600,
       "subnet4": [
         {
           "subnet": "192.168.200.0/24",
           "pools": [{ "pool": "192.168.200.100 - 192.168.200.110" }],
           "option-data": [
             { "name": "routers", "data": "192.168.200.254" },
             { "name": "domain-name", "data": "learn-it.local" },
             { "name": "domain-name-servers", "data": "192.168.200.254" }
           ]
         }
       ]
     }
   }
   ```

   _Assurez-vous de remplacer `enp0s8` par le nom de votre interface interne._

3. **Démarrer et activer Kea DHCP** :

   ```bash
   sudo systemctl enable kea-dhcp4-server
   sudo systemctl start kea-dhcp4-server
   ```

### **Vérifier le Fonctionnement du DHCP**

1. **Configurer le Client Windows pour Obtenir une IP Automatiquement**

2. **Vérifier qu'il Obtient une Adresse dans la Plage `192.168.200.100 - 192.168.200.110`**

3. **Tester la Connectivité et la Résolution DNS**

### **Comprendre l'Utilisation des Logs avec `journalctl`**

- **Consulter les logs de Kea DHCP** :

  ```bash
  sudo journalctl -u kea-dhcp4-server
  ```

- **Suivre les logs en temps réel** :

  ```bash
  sudo journalctl -f -u kea-dhcp4-server
  ```

---
