# 02 - Configuration réseau et interfaces

## ⚙️ Exemple `/etc/network/interfaces`

```text
auto lo
iface lo inet loopback

# WAN (NAT) via DHCP
auto ens33
iface ens33 inet dhcp

# DMZ
auto ens34
iface ens34 inet static
    address 192.168.34.1/24

# LAN
auto ens38
iface ens38 inet static
    address 192.168.38.1/24
```

> Adaptez les noms d’interfaces si nécessaire (ex. `enp0s3`, `enp0s8`…).

---

## ✅ Activer le routage IPv4

```bash
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-forwarding.conf
sysctl -p /etc/sysctl.d/99-forwarding.conf
```
