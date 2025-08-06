# homelab

## Setup

### Basic

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
sudo apt install -y curl openssh-server git vim samba htop zsh tmux nfs-common
```

4. Change the default shell to zsh

```sh
chsh -s $(which zsh)
```

### SSH

1. Generate an SSH key (skip this step if you already have an SSH key)

```sh
ssh-keygen
```

2. Copy the public key to the server

```sh
ssh-copy-id <username>@<server-ip>
```

[Reference](https://askubuntu.com/a/46935)

### Tailscale

```sh
curl -fsSL https://tailscale.com/install.sh | sh
```

[Reference](https://tailscale.com/download/linux)

### Git

```sh
git config --global user.email example@email.com
git config --global user.name 'Your Name'
```

[Reference](https://stackoverflow.com/a/33024593/11027944)

### Docker

[Reference](https://docs.docker.com/engine/install/ubuntu/)

### Install NVIDIA drivers (if you have an NVIDIA GPU)

Find the latest driver version [here](https://www.nvidia.com/en-us/drivers/unix/).

```sh
sudo apt purge nvidia-*
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update
sudo apt install nvidia-driver-***
sudo reboot
```

[Reference](https://askubuntu.com/a/903781/2286402)

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