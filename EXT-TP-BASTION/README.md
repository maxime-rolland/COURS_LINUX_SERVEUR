# EXTENSION_BASTION

---

## **Objectifs**

L'objectif est d'étendre notre TP pour ajouter un bastion à notre réseau.

-- Mettre explication Bastion ICI ---

## **Installer Docker**

L'installation d'Apache Guacamole est plus simple à implémenter et maintenir en utilisant Docker.

-- ici explication rapide Docker --
-- ICI procédure installation Docker , parrtir site officiel ---

Commande qui permet de récupèrer le fichier d'initialisation de la BDD
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql

docker compose up -d

cat initdb.sql | docker exec -i bastion-db-1 /usr/bin/mysql -u user --password=Azerty01 guacamoledb

-- faire capture d'écran UI web  --
