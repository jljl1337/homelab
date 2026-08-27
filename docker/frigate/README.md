# frigate

## video devices

To allow all user to have access to all video devices, run the following command:

```sh
sudoedit /etc/udev/rules.d/99-video.rules
```

And add the following line:

```
SUBSYSTEM=="video4linux", MODE="0666"
```

Then reload the udev rules:

```sh
sudo udevadm control --reload-rules
sudo udevadm trigger
```
