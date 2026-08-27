# homelab

## Fedora installation

Download [Fedora Media Writer](https://github.com/FedoraQt/MediaWriter/releases)
and the [Fedora Server ISO](https://fedoraproject.org/server/download/), and
create a bootable USB drive.

On macOS, run the following command to remove the quarantine attribute from
the Fedora Media Writer app:

```sh
xattr -d com.apple.quarantine /Applications/FedoraMediaWriter.app
```

When installing Fedora, disable Secure Boot and Legacy Boot, use UEFI boot only.
If still not able to boot, disable Fast Boot, try USB ports with 2.0 speeds.

With NVIDIA GPU, in the GRUB boot menu, press `e` to edit the boot parameters,
and add `nomodeset` to the end of the line starting with `linux`, then press
`Ctrl + X` to boot.

## Setup

### Prerequisites

Setup dotfiles from [here](https://github.com/jljl1337/dotfiles)

### Basic

1. Update the packages

```sh
sudo dnf upgrade -y
```

2. Reboot

```sh
sudo reboot
```

### SSH

1. On your client, generate an SSH key (skip this step if you already have an
SSH key)

```sh
ssh-keygen -t ed25519
```

2. Copy the public key to the server

```sh
ssh-copy-id <username>@<server-ip>
```

3. Disable password authentication by
`sudoedit /etc/ssh/sshd_config.d/50-disable-password.conf` and set the
following options:

```conf
PasswordAuthentication no
```

### Firewall

Add the following rules to the firewall:

```sh
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=samba
```

Reload the firewall:

```sh
sudo firewall-cmd --reload
```

Verify the firewall rules:

```sh
sudo firewall-cmd --list-all
```

### Netbird 

Go to [Netbird dashboard](https://app.netbird.io/peers) and select "Add peer",
and select "Server" and copy the command to run on the server.

### ZFS

To install, follow the instructions from
[here](https://openzfs.github.io/openzfs-docs/Getting%20Started/Fedora/index.html#installation).

To list all available ZFS pools to be imported, run the following command:

```sh
sudo zpool import
```

To import a ZFS pool, run the following command:

```sh
sudo zpool import <pool-name>
```

To mount a ZFS pool, run the following command:

```sh
sudo zfs mount <pool-name>
```

To specify a mount point for a ZFS pool, run the following command:

```sh
sudo zfs set mountpoint=/path/to/mount <pool-name>
```

To enable auto-mounting of ZFS pools on boot, run the following command:

```sh
sudo systemctl enable zfs-import-cache.service
sudo systemctl enable zfs-import-scan.service
sudo systemctl enable zfs-mount.service
sudo systemctl enable zfs.target
```

To export a ZFS pool before migrating to another system, run the following
command:

```sh
sudo zpool export <pool-name>
```

### SMB Share

To install, run the following command:

```sh
sudo dnf install samba samba-common samba-client
```

Since some containers require read/write access to the SMB share, you need to
enable SMB to allow read/write access to all files by running the following
command:

```sh
sudo setsebool -P samba_export_all_rw on
```

SMB uses user from the host system, but the password is stored separately, to
set the password for the user, run the following command:

```sh
sudo smbpasswd -a <username>
```

To enable the user, run the following command:

```sh
sudo smbpasswd -e <username>
```

Edit the `/etc/samba/smb.conf` file and add the following lines under the
`[global]` section for iOS write access:

```conf
vfs objects = streams_xattr
```

Add a new section for each share:
```conf
[myshare]
path = /path/to/share
valid users = username
guest ok = no
writable = yes
browsable = yes
```

Start the SMB service and enable it to start on boot:

```sh
sudo systemctl enable --now smb nmb
```

### Install NVIDIA firmwares (if you have an NVIDIA GPU)

Install kernel headers for module building:

```sh
sudo dnf install -y kernel-devel kernel-headers gcc make dkms acpid
```

To install the driver, see the instructions from
[here](https://rpmfusion.org/Howto/NVIDIA#Installing_the_drivers), different
GPU architectures have different instructions, so make sure to follow the
correct instructions for the GPU architecture you have.

Wait until the module is built, to verify that the module is built, run the following command:

```sh
modinfo -F version nvidia
```

It should print the version of the NVIDIA driver and not
`modinfo: ERROR: Module nvidia not found.`

To rebuild the module, run the following command:

```sh
sudo akmods --force
```

Then reboot with `sudo reboot` and verify with this command:

```sh
nvidia-smi
```

### Unprivileged ports

Enable rootless Docker to bind to privileged ports by running the following
commands:

```sh
sudo sysctl -w net.ipv4.ip_unprivileged_port_start=0
echo 'net.ipv4.ip_unprivileged_port_start=0' | sudo tee /etc/sysctl.d/99-rootless-docker-ports.conf
```

To verify:

```sh
sysctl net.ipv4.ip_unprivileged_port_start
```

Something like this should be printed:

```
net.ipv4.ip_unprivileged_port_start = 0
```

If not, apply the changes with:

```sh
sudo sysctl --system
```

### Docker (rootless)

Setup the repository:

```sh
sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
```

Install Docker:

```sh
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Then skip starting the rootful service, and install the rootless service:

```sh
dockerd-rootless-setuptool.sh install
```

Verify the context:

```sh
docker info
```

Setup Docker socket

```sh
systemctl --user enable --now docker.socket
```

Enable lingering (so it runs after logout):

```sh
loginctl enable-linger $USER
```

To allow rootless to access the ports of the host with `10.0.2.2`, edit
`~/.config/systemd/user/docker.service.d/override.conf` and add the following
lines:

```ini
[Service]
Environment="DOCKERD_ROOTLESS_ROOTLESSKIT_DISABLE_HOST_LOOPBACK=false"
```

Then reload the systemd daemon and restart Docker:

```sh
systemctl --user daemon-reload
systemctl --user restart docker
```

### Enable GPU support for rootless Docker

Add the NVIDIA repository:

```sh
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
  sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
```

Install the NVIDIA container toolkit:

```sh
sudo dnf install -y nvidia-container-toolkit
```

Generate the CDI specs:

```sh
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

Verify the CDI specs:

```sh
nvidia-ctk cdi list
```

Verify with GPU access:

```sh
docker run --rm --device nvidia.com/gpu=all docker.io/nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```

If it does not work, restart the Docker service:

```sh
systemctl --user restart docker
```

If it still does not work, run
`sudoedit /etc/nvidia-container-runtime/config.toml` and change the
`no-cgroups` option to `true`:

```toml
no-cgroups = true
```

If it still does not work, create `~/.config/docker/daemon.json` to configure
the NVIDIA runtime for rootless Docker:

```json
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "args": []
        }
    }
}
```

## Usage

### Docker Services

1. Copy the `.env.example` file to `.env` and set the environment variables.
2. Run `docker compose up -d --remove-orphans` to start the services.

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
