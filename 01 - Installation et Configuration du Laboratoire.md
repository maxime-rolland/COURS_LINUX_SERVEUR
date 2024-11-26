# **Étape 1 : Installation et configuration du laboratoire**

## **Installer server1**

- **Système d'exploitation** : Debian 12 (Bookworm)
- **Ressources** :

  - **Deux cartes réseau** :
    - **Interface 1** : Configurée en **NAT** pour l'accès à Internet.
    - **Interface 2** : Configurée en **"Réseau interne"** nommé **intnet**.

- **Paramètres système** :

  - **Nom du serveur** : `server1`
  - **Nom de domaine** : `learn-it.local`
  - **Mot de passe root** : `Azerty01`
  - **Utilisateur** : Créez un utilisateur nommé `user` avec le mot de passe `Azerty02`.

## **Installer server2**

- **Système d'exploitation** : Debian 12 (Bookworm)
- **Ressources** :

  - **Une carte réseau** :
    - **Interface** : Configurée en **"Réseau interne"** nommé **intnet**.

- **Paramètres système** :

  - **Nom du serveur** : `server2`
  - **Mot de passe root** : `Azerty01`
  - **Utilisateur** : Créez un utilisateur nommé `user` avec le mot de passe `Azerty02`.

## **Installer le client Windows**

- **Système d'exploitation** : Windows 10 ou Windows 11
- **Ressources** :

  - **Une carte réseau** :
    - **Interface** : Connectée au réseau interne **intnet**.

- **Paramètres système** :

  - **Nom de l'ordinateur** : `client`
  - **Utilisateur** : Créez un utilisateur (par exemple, `user`) avec le mot de passe de votre choix.

---
