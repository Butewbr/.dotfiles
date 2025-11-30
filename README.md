# My dotfiles

This directory contains the dotfiles for my Arch-Linux system.

## Requirements

### Git

```bash
pacman -S git
```

### Stow

```bash
pacman -S stow
```

## Installation

First, check out the dotfiles repo in your `$HOME` directory using `git`

```bash
git clone git@github.com/Butewbr/.dotfiles.git
cd .dotfiles
```

Give permission to the `stow.sh` script:

```bash
chmod +x ./stow.sh
```

Run the script:

```bash
./stow.sh
```


## Dual Monitor problems - Hyprland + Integrated Graphics + Nvidia

Load modules from both GPUs on `/etc/mkinitcpio.conf`:

```conf
MODULES=(i915 btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

And add the `env` to use both GPUs on `hyprland.conf`:

```conf
env = AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1
```