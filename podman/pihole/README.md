# pihole

This is used for ad blocking when connected to the VPN.
It is not used for the local network.

Recommended blocklist for pihole: 

```
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt
```

[Reference](https://github.com/hagezi/dns-blocklists#pro)

## Troubleshooting

For port conflict issue of pihole on Ubuntu:

```sh
sudo sh -c 'mkdir -p /etc/systemd/resolved.conf.d && printf "[Resolve]\nDNSStubListener=no\n" | tee /etc/systemd/resolved.conf.d/no-stub.conf'
```

```sh
sudo sh -c 'rm -f /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'
```

```sh
sudo systemctl restart systemd-resolved
```

[Reference](https://docs.pi-hole.net/docker/tips-and-tricks/#disable-systemd-resolved-port-53).
