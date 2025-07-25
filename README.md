# homelab

## Setup

1. Update the system

```sh
sudo apt update
sudo apt upgrade -y
```

2. Reboot

```sh
sudo reboot
```

3. Install packages

```sh
sudo apt install -y curl openssh-server git vim samba htop zsh
```

4. Change the default shell to zsh

```sh
chsh -s $(which zsh)
```

5. Setup these as you need

- [ssh key](https://askubuntu.com/a/46935)
- [tailscale](https://tailscale.com/download/linux)
- [git username and email](https://stackoverflow.com/a/33024593/11027944)
- [Docker](https://docs.docker.com/engine/install/ubuntu/)
- [RustDesk](https://rustdesk.com/download)

## Usage

### Samba

1. Copy the content of `smb.conf` to the end of `/etc/samba/smb.conf`.
2. Add the user to the Samba database.

```sh
sudo smbpasswd -a <username>
```

3. Restart the Samba service.

```sh
sudo systemctl restart smbd
```

### Docker

1. Run `docker network create traefik` to create the Traefik network.
2. Copy the `.env.example` file to `.env` and set the environment variables.
3. Run `docker compose up -d` to start the services.

For pihole on Ubuntu, see [here](https://docs.pi-hole.net/docker/tips-and-tricks/#disable-systemd-resolved-port-53).

### Restore backup

1. Copy the `.env.example` file to `.env` and set the environment variables for restic.
2. Start the restic container with the following command:

```sh
docker run -it --env-file .env -v <restore-location>:/mnt/restore --entrypoint sh restic/restic
```

Get all the snapshots and the corresponding id:

```sh
restic snapshots
```

Get the files in the snapshot:

```sh
restic ls <snapshot-id>
```

Restore the files:

```sh
restic restore <snapshot-id>:/mnt/source --target /mnt/restore/
```

## Development (Docker)

1. Edit the `compose.yml` file and the yaml files in the `docker` to add or remove services.
2. Add the environment variables to the `.env` file.
3. Run `env_example.sh` to generate the new `.env.example` file.