# grafana

## node-exporter

Install node-exporter as a systemd service:

```sh
sudo dnf install node_exporter
sudo systemctl enable --now node_exporter
```

## cadvisor

Allow cAdvisor to run in a user namespace by creating a systemd override for
the `user@.service` unit:

```sh
sudo mkdir -p /etc/systemd/system/user@.service.d

sudo tee /etc/systemd/system/user@.service.d/delegate.conf <<EOF
[Service]
Delegate=cpu cpuset io memory pids
EOF
```

Reload the systemd daemon and restart the user service:

```sh
sudo systemctl daemon-reload
systemctl --user restart docker.service
```

