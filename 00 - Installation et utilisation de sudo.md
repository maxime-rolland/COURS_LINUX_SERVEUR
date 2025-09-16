# **Étape : Installation et utilisation de sudo**

## **Introduction à `sudo`**

- **Qu'est-ce que `sudo` ?**
  - `sudo` (Super User DO) est un programme qui permet à un utilisateur d'exécuter des commandes avec les privilèges d'un autre utilisateur, par défaut l'utilisateur `root`.
  - Il est essentiel pour effectuer des tâches administratives sans avoir à se connecter directement en tant que `root`, améliorant ainsi la sécurité du système.

- **Pourquoi utiliser `sudo` ?**
  - Limite les risques associés à l'utilisation du compte `root`.
  - Permet de tracer les actions des utilisateurs.
  - Offre un contrôle granulaire sur les permissions.

## **Installation de `sudo` sur Debian 13**

Par défaut, Debian 13 n'installe pas le paquet `sudo` lors de l'installation minimale. Vous devez donc l'installer manuellement.

1. **Se connecter en tant que `root`**

   - Si vous êtes connecté en tant qu'utilisateur normal (par exemple, `user`), vous devez d'abord passer à l'utilisateur `root` :

     ```bash
     su -
     ```

     - Entrez le mot de passe `root` (`Azerty01`).

2. **Installer le paquet `sudo`**

   - Mettez à jour la liste des paquets :

     ```bash
     apt update
     ```

   - Installez `sudo` :

     ```bash
     apt install sudo
     ```

## **Ajouter un utilisateur au groupe `sudo`**

Pour permettre à un utilisateur d'exécuter des commandes avec `sudo`, vous devez l'ajouter au groupe `sudo`.

1. **Ajouter l'utilisateur `user` au groupe `sudo`**

   ```bash
   usermod -aG sudo user
   ```

   - **Explication** :
     - `usermod` : Commande pour modifier les informations d'un utilisateur.
     - `-aG sudo` : Ajoute (`a`) l'utilisateur aux groupes (`G`), ici le groupe `sudo`.
     - `user` : Nom de l'utilisateur à modifier.

2. **Vérifier que l'utilisateur a été ajouté au groupe `sudo`**

   - Affichez les groupes de l'utilisateur :

     ```bash
     groups user
     ```

     - La sortie devrait inclure `sudo` :

       ```bash
       user : user sudo
       ```

## **Redémarrer la Session Bash**

Les changements de groupes ne prennent effet qu'après une nouvelle connexion. Vous devez donc vous déconnecter et vous reconnecter pour que les modifications soient appliquées.

1. **Se déconnecter de la session `root`**

   ```bash
   exit
   ```

2. **Se déconnecter de la session utilisateur**

   - Si vous êtes en SSH, déconnectez-vous :

     ```bash
     exit
     ```

   - Si vous êtes sur la console, déconnectez-vous de la session.

3. **Se reconnecter en tant que `user`**

   - Connectez-vous avec votre nom d'utilisateur (`user`) et votre mot de passe (`Azerty02`).

4. **Vérifier que `sudo` fonctionne**

   - Testez une commande avec `sudo` :

     ```bash
     sudo apt update
     ```

   - La première fois, vous serez invité à entrer votre mot de passe utilisateur (`Azerty02`) et à accepter un avertissement de sécurité.

   - Si la commande s'exécute sans erreur, `sudo` est correctement configuré.

## **Conseils de sécurité pour l'utilisation de `sudo`**

- **Utiliser `sudo` avec Précaution**

  - N'utilisez `sudo` que lorsque c'est nécessaire.
  - Évitez d'exécuter des commandes potentiellement dangereuses.

- **Auditer les Actions**

  - Les commandes exécutées avec `sudo` sont généralement enregistrées dans les logs système, ce qui permet de tracer les actions en cas de besoin.

- **Ne Pas Utiliser `sudo` pour Ouvrir une Session Permanente**

  - Évitez d'utiliser `sudo su` ou `sudo -i` pour ouvrir une session `root`.
  - Préférez exécuter des commandes individuelles avec `sudo` pour limiter les risques.

## **Utilisation de `sudo` dans le TP**

Maintenant que `sudo` est installé et configuré, vous pouvez l'utiliser pour toutes les commandes nécessitant des privilèges élevés dans les étapes suivantes du TP.

- **Exemples** :

  - Installation de paquets :

    ```bash
    sudo apt install nom_du_paquet
    ```

  - Édition de fichiers système :

    ```bash
    sudo nano /etc/nom_du_fichier
    ```

  - Redémarrage de services :

    ```bash
    sudo systemctl restart nom_du_service
    ```

## **Notes importantes**

- **Ne partagez pas votre mot de passe**

  - Votre mot de passe utilisateur vous permet d'exécuter des commandes avec `sudo`. Ne le partagez pas avec d'autres utilisateurs.

- **Garder le système à jour**

  - Utilisez régulièrement `sudo apt update` et `sudo apt upgrade` pour maintenir votre système sécurisé.

- **Configurer `sudoers` si nécessaire**

  - Le fichier `/etc/sudoers` détermine les permissions accordées aux utilisateurs et aux groupes.
  - Pour des configurations avancées, utilisez la commande `visudo` pour éditer ce fichier en toute sécurité :

    ```bash
    sudo visudo
    ```

  - **Attention** : Une mauvaise configuration du fichier `sudoers` peut entraîner des problèmes de sécurité ou empêcher l'utilisation de `sudo`.

---

## **Conclusion**

Vous avez maintenant installé et configuré `sudo` sur votre système Debian 13, ce qui vous permettra d'administrer votre système de manière sécurisée et efficace. Cette étape est cruciale pour les administrateurs système, car elle offre un meilleur contrôle des privilèges et contribue à la sécurité globale du système.

Assurez-vous d'utiliser `sudo` judicieusement tout au long du TP et de respecter les bonnes pratiques de sécurité.

---
