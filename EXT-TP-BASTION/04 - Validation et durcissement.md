# 04 - Validation et durcissement

## ✅ Checklist de validation

### 1) Publication Guacamole

```bash
curl -I http://<IP_WAN_DEBIAN>:8080/guacamole
```

Si cela échoue, tester :

```bash
curl -I http://<IP_WAN_DEBIAN>:8080/
```

➡️ Si `/` fonctionne mais pas `/guacamole`, c’est la **config du reverse proxy docker** qui ne route pas ce chemin.

---

### 2) Guacamole → LAN (SSH/RDP uniquement)

Depuis `192.168.34.2` :

```bash
nc -vz 192.168.38.10 22
nc -vz 192.168.38.10 3389
nc -vz 192.168.38.10 80    # doit échouer
```

---

### 3) LAN → Internet via NAT

Depuis une machine LAN :

```bash
ping 8.8.8.8
curl https://example.com
```

---

## 🔐 Durcissement (bonus)

### Restreindre DMZ → Internet uniquement à Guacamole

Remplacer :

```nft
iifname $DMZ_IF oifname $WAN_IF ip saddr $DMZ_NET accept
```

par :

```nft
iifname $DMZ_IF oifname $WAN_IF ip saddr $GUAC_PROXY_IP accept
```

---

## ✅ Résultat attendu

* L’accès externe au bastion se fait via :

  ✅ `http://<IP_EXT>:8080/guacamole`

* Le LAN reste protégé :

  * ❌ aucun accès direct depuis WAN
  * ✅ accès SSH/RDP uniquement depuis Guacamole

* Le LAN sort sur Internet via NAT ✅
