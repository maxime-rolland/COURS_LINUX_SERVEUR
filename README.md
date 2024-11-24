# COURS_LINUX_SERVEUR

---

## **Objectifs**

L'objectif de ces exercices est de simuler un réseau d'entreprise simple en configurant plusieurs services réseau sur des machines virtuelles. Vous allez apprendre à installer et configurer des serveurs Linux, à mettre en place des services essentiels tels que DNS, DHCP, passerelle réseau, serveurs web, et à sécuriser vos connexions avec SSH.

**Étapes du TP :**

1. **Installation et configuration du laboratoire**

   - Installer **Server1** (Debian 12)
   - Installer **Server2** (Debian 12)
   - Installer le **client Windows**

2. **Configuration des interfaces réseau**

   - Configurer les interfaces réseau de **Server1**
   - Configurer les interfaces réseau de **Server2**
   - Configurer l'interface réseau du **client Windows**

3. **Connexion SSH aux serveurs**

   - Installer le **serveur SSH** sur Server1 et Server2
   - Générer une **paire de clés SSH** sur le client Windows
   - Configurer l'**authentification par clé SSH** sur les serveurs
   - Se connecter en SSH depuis le client Windows

4. **Mise à jour de Server1**

   - Vérifier et configurer le fichier **`sources.list`**
   - Mettre à jour le système
   - Comprendre l'importance du fichier `sources.list` et sa sécurité

5. **Transformation de Server1 en passerelle réseau**

   - **Comprendre le routage**, les passerelles, et l'intérêt du **NAT/PAT** (masquerade)
   - Comprendre **nftables** (framework NetFilter)
   - Activer le **routage IP**
   - Configurer **nftables** étape par étape pour le NAT
   - Tester l'accès Internet depuis le réseau interne

6. **Transformation de Server1 en serveur DNS**

   - Installer et configurer **Bind9**
   - Créer les **fichiers de zone** (directe et inverse)
   - Configurer les **permissions** appropriées
   - Tester la **résolution DNS**

7. **Transformation de Server1 en serveur DHCP avec Kea**

   - Installer **Kea DHCP**
   - Configurer Kea pour votre réseau
   - Vérifier le fonctionnement du DHCP
   - Comprendre l'utilisation des **logs avec `journalctl`**

8. **Transformation de Server2 en serveur LAMP**

   - Installer **Apache**, **MariaDB** et **PHP**
   - Configurer les services
   - Comprendre les services sous Linux et la **gestion des permissions**

9. **Installation de services web**

   - Installer **WordPress** pour `site1.learn-it.local` et `site2.learn-it.local`
   - Installer un autre **CMS** pour `site3.learn-it.local`
   - Installer **GLPI** pour `glpi.learn-it.local`
   - Configurer les **VirtualHosts** et les **entrées DNS**
   - Comprendre les spécificités de configuration pour **GLPI**

**Conseils généraux :**

- Travaillez **étape par étape** et assurez-vous de comprendre chaque configuration avant de passer à la suivante.
- **Documentez** vos actions et prenez des notes pour faciliter le dépannage.
- N'hésitez pas à utiliser les outils de logs comme **`journalctl`** pour diagnostiquer les problèmes.
- Faites attention aux **permissions** et à la **sécurité** lors de la configuration des services.

---
