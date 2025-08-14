# homelab

## Setup

### Basic

1. Update the packages

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
sudo apt install -y curl openssh-server git vim htop zsh tmux nfs-common v4l-utils ffmpeg
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

### Install NVIDIA firmwares (if you have an NVIDIA GPU)

1. Install driver by replacing `***` with the latest version number from
[here](https://www.nvidia.com/en-us/drivers/unix/) and run:

```sh
sudo apt purge nvidia-*
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update
sudo apt install nvidia-driver-***
sudo reboot
```

[Reference](https://askubuntu.com/a/903781/2286402)

2. Install [Container toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

3. Reboot

### NFS Client

1. Create a directory to mount the NFS share

```sh
sudo mkdir -p /local/path/to/nfs
```

2. Open the `/etc/fstab` file

```sh
sudoedit /etc/fstab
```

Add the following line to the end of the file:

```
<server-ip>:/server/path/to/nfs/share /local/path/to/nfs nfs defaults,_netdev 0 0
```

3. Mount the NFS share

```sh
sudo mount /local/path/to/nfs
```

[Reference](https://linuxize.com/post/how-to-mount-an-nfs-share-in-linux/#automatically-mounting-nfs-file-systems-with-etcfstab)

## Usage

### Docker Services

1. Copy the `.env.example` file to `.env` and set the environment variables.
2. Run `docker compose up -d` to start the services.

For port conflict issue of pihole on Ubuntu, see [here](https://docs.pi-hole.net/docker/tips-and-tricks/#disable-systemd-resolved-port-53).

Recommended blocklist for pihole: https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt

### Restore backup

1. Copy the `.env.example` file to `.env` and set the environment variables for restic.
2. Start the restic container with the following command:

```sh
docker run --rm -it --env-file .env -v <restore-location>:/mnt/restore --entrypoint sh restic/restic
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