# **Étape 7 : Transformation de server1 en serveur DHCP avec Kea**

## **Installer Kea DHCP**

```bash
sudo apt install kea-dhcp4-server
```

## **Configurer Kea pour votre réseau**

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

## **Vérifier le fonctionnement du DHCP**

1. **Configurer le client Windows pour obtenir une IP automatiquement**

2. **Vérifier qu'il obtient une adresse dans la Plage `192.168.200.100 - 192.168.200.110`**

3. **Tester la connectivité et la résolution DNS**

## **Comprendre l'utilisation des Logs avec `journalctl`**

- **Consulter les logs de Kea DHCP** :

  ```bash
  sudo journalctl -u kea-dhcp4-server
  ```

- **Suivre les logs en temps réel** :

  ```bash
  sudo journalctl -f -u kea-dhcp4-server
  ```

---
