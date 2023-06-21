# SolidRun Debian 11 - Release 9

## Summary

- Upstream Release: Debian 11
- SolidRun Release: 11
- Hardware
  - i.MX8MP CuBox-M
  - i.MX8MP Hummingbord Pulse
- Features:
  - Ports:
    - microSD
    - Ethernet
      - primary interface
      - secondary interface
    - SoM integrated WiFi+Bluetooth
    - 2x USB-3.0 Type A
    - HDMI
    - microHDMI
    - eMMC
    - 3.5mm stereo-out and microphone-in jack
  - Multimedia:
    - ALSA Audio Playback
      - HDMI
      - 3.5mm jack
- Major Components:
  - [Linux 5.10.72](https://github.com/SolidRun/linux-stable/tree/lf-5.10.72-2.2.0-sr)

## Download

- [i.MX8MP, microSD bootable](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-bullseye-20230623-cli-imx8mp-sdhc.img.xz)

# Documentation

## Install

All images are designed for raw deployment byte by byte (**not as a file**) to block storage such as microSD cards. Several tools can be used, including `dd`, `win32diskimager` and [etcher.io](https://etcher.io/). Note that care must be taken to decompress the image file for the first 2, while *etcher.io* can also handle the compressed image.

### Install to eMMC

The eMMC is accessible from the running system by varying names depending on the particular SoC. It can be identified by the special partitions such as boot0: e.g. if `/dev/mmcblk2boot0` exists, /dev/mmcblk2 is the eMMC. Install the
Debian software image to eMMC by writing the image directly to the data partition:

	xzcat sr-imx8-debian-bullseye-20220407-cli-imx8mp-sdhc.img.xz | dd of=/dev/mmcblk2 bs=4k conv=fdatasync

Set SW3 DIP switches to boot from eMMC as documented in the [HummingBoard Pulse Boot Select](https://solidrun.atlassian.net/wiki/spaces/developer/pages/287343073/HummingBoard+Pulse+and+Ripple+Boot+Select) article.
Also make sure to remove any microSD that contains the **same** image that was flashed to eMMC, as it can cause conflicts in rootfs identification.

## Usage Hints

### ALSA Examples

    sudo apt install vorbis-tools
    wget https://github.com/KDE/amarok/raw/master/data/first_run_jingle.ogg
    ogg123 -d alsa -o dev:dmix:CARD=wm8904audio first_run_jingle.ogg
    ogg123 -d alsa -o dev:dmix:CARD=audiohdmi first_run_jingle.ogg

## Get Started

Once you are greeted by a login prompt, the default username and password are both "debian". For security reasons there is **no** root password! If you really need one, you can run `sudo passwd root` to set your own.

## Known Issues

## Customize

### Creating custom images

Since Bullseye we are using a custom tool built on [KIWI-NG](https://osinside.github.io/kiwi/) to generate the bootable disk images.
We make it available [here on our GitHub](https://github.com/SolidRun/debian-builder/tree/master) for general use. If you want to use it and have any questions, please contact support.

### Using custom Device-Tree Blobs

We are trying to follow Debian design patterns where possible especially in the boot process. The *flash-kernel* application is used for installing DTBs to /boot as well as creating a boot-script for u-boot to load kernel, ramdisk and dtb.

Using a custom DTB here is as simple as putting it in **/etc/flash-kernel/dtbs** and rerunning `flash-kernel`. From this point onwards whenever an update to the kernel, or parts of the ramdisk occurs *flash-kernel* will automatically pick up the provided DTB in /etc.

## Pure Debian (upstream)

Our long-term goal is enabling as much of our hardware upstream as part of Debian where feasible. Success is highly dependent on the efforts of the general community around the i.MX8M SoCs, as well as the amount of proprietary blobs involved. At this point no support for the SolidRun i.MX8M boards is present in Debian.
