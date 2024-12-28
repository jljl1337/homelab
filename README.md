# homelab

## Setup

1. Update the system

```bash
sudo apt update
sudo apt upgrade -y
```

2. Reboot

```bash
sudo reboot
```

3. Install packages

```bash
sudo apt install -y curl openssh-server git vim samba
```

4. Setup these as you need

- [ssh key](https://askubuntu.com/a/46935)
- [tailscale](https://tailscale.com/download/linux)
- [git username and email](https://stackoverflow.com/a/33024593/11027944)
- [Docker](https://docs.docker.com/engine/install/ubuntu/)
- [AnyDesk](https://anydesk.com/en/downloads/linux)
- [Sunshine](https://docs.lizardbyte.dev/projects/sunshine/en/latest/about/setup.html)

Restart the service if having issues to connect to the sunshine server:

```bash
systemctl --user restart sunshine
```

## Usage

### Samba

1. Copy the content of `smb.conf` to the end of `/etc/samba/smb.conf`.
2. Add the user to the Samba database.

```bash
sudo smbpasswd -a <username>
```

3. Restart the Samba service.

```bash
sudo systemctl restart smbd
```

### Docker

1. Copy the `.env.example` file to `.env` and set the environment variables.
2. Run `docker-compose up -d` to start the services.

## Development (Docker)

1. Edit the `docker-compose.yml` file to add or remove services.
2. Add the environment variables to the `.env` file.
3. Run `env_example.sh` to generate the new `.env.example` file.