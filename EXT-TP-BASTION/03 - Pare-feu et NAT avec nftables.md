# 03 - Pare-feu et NAT avec nftables

## 🧱 Configuration `nftables`

📌 À placer dans `/etc/nftables.conf`

```nft
#!/usr/sbin/nft -f

flush ruleset

define WAN_IF        = "ens33"
define DMZ_IF        = "ens34"
define LAN_IF        = "ens38"

define DMZ_NET       = 192.168.34.0/24
define LAN_NET       = 192.168.38.0/24

define GUAC_PROXY_IP = 192.168.34.2

table inet filter {

  chain input {
    type filter hook input priority 0;
    policy drop;

    iif "lo" accept
    ct state established,related accept

    ip protocol icmp accept
    ip6 nexthdr icmpv6 accept

    # SSH admin uniquement depuis l'hôte (192.168.88.1)
    iifname $WAN_IF ip saddr 192.168.88.1 tcp dport 22 accept
  }

  chain forward {
    type filter hook forward priority 0;
    policy drop;

    ct state established,related accept

    # LAN -> Internet
    iifname $LAN_IF oifname $WAN_IF ip saddr $LAN_NET accept

    # DMZ -> Internet (optionnel mais utile)
    iifname $DMZ_IF oifname $WAN_IF ip saddr $DMZ_NET accept

    # Publication Guacamole : WAN:8080 -> DMZ:8080
    iifname $WAN_IF oifname $DMZ_IF ip daddr $GUAC_PROXY_IP tcp dport 8080 accept

    # Guacamole -> LAN : SSH + RDP uniquement
    iifname $DMZ_IF oifname $LAN_IF ip saddr $GUAC_PROXY_IP ip daddr $LAN_NET tcp dport {22, 3389} accept
  }

  chain output {
    type filter hook output priority 0;
    policy accept;
  }
}

table ip nat {

  chain prerouting {
    type nat hook prerouting priority -100;
    policy accept;

    # DNAT : WAN:8080 -> DMZ:8080
    iifname $WAN_IF tcp dport 8080 dnat to $GUAC_PROXY_IP:8080
  }

  chain postrouting {
    type nat hook postrouting priority 100;
    policy accept;

    # NAT sortant LAN -> WAN
    oifname $WAN_IF ip saddr $LAN_NET masquerade

    # NAT sortant DMZ -> WAN
    oifname $WAN_IF ip saddr $DMZ_NET masquerade
  }
}
```

---

## 🔄 Activation / rechargement

```bash
systemctl enable nftables
systemctl restart nftables
nft list ruleset
```
