# SolidRun Debian 11 - Release 2

## Summary

- Upstream Release: Debian 11 (testing)
- SolidRun Release: 2
- Hardware
  - i.MX8MM Hummingbord Pulse
  - i.MX8MP Hummingbord Pulse
  - i.MX8MQ Hummingbord Pulse
- Features:
  TBD
- Major Components:
  - [Linux 5.4.47](https://github.com/SolidRun/linux-stable/tree/linux-5.4.y-imx8)
  - NXP Graphics SDK 6.4.3.p0

## Download

- [i.MX8MM Hummingboard Pulse, microSD bootable](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-bullseye-20201123-cli-imx8mm-sdhc-hummingboard-pulse.img.xz)
- [i.MX8MP HummingBoard Pulse, microSD bootable](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-bullseye-20201123-cli-imx8mp-sdhc-hummingboard-pulse.img.xz)
- [i.MX8MQ HummingBoard Pulse, microSD bootable](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-bullseye-20201123-cli-imx8mq-sdhc-hummingboard-pulse.img.xz)

# Documentation

## Install

All images are designed for raw deployment byte by byte (**not as a file**) to block storage such as microSD cards. Several tools can be used, including `dd`, `win32diskimager` and [etcher.io](https://etcher.io/). Note that care must be taken to decompress the image file for the first 2, while *etcher.io* can also handle the compressed image.

### Install to eMMC

The eMMC is accessible from the running system as `/dev/mmcblk2`. Install the
Debian software image to eMMC by writing the image directly to `/dev/mmcblk2`:

	xzcat sr-imx8-debian-buster-20191120-cli-imx8mq-sdhc.img.xz | dd of=/dev/mmcblk2 bs=4k conv=fdatasync

Set SW3 DIP switches to boot from eMMC as documented in the [HummingBoard
Pulse Boot
Select](https://solidrun.atlassian.net/wiki/spaces/developer/pages/287343073/HummingBoard+Pulse+and+Ripple+Boot+Select)
article.
Also make sure to remove any microSD that contains the **same** image that was flashed to eMMC, as it can cause conflicts in rootfs identification.

## Get Started

Once you are greeted by a login prompt, the default username and password are both "debian". For security reasons there is **no** root password! If you really need one, you can run `sudo passwd root` to set your own.

## Known Issues

### mini-PCIe not functional on i.MX8MQ

This is a problem with NXPs 5.4 kernel release, which does not properly support pcie on the i.MX8MQ SoC.

## Customize

### Using custom Device-Tree Blobs

We are trying to follow Debian design patterns where possible especially in the boot process. The *flash-kernel* application is used for installing DTBs to /boot as well as creating a boot-script for u-boot to load kernel, ramdisk and dtb.

Using a custom DTB here is as simple as putting it in **/etc/flash-kernel/dtbs** and rerunning `flash-kernel`. From this point onwards whenever an update to the kernel, or parts of the ramdisk occurs *flash-kernel* will automatically pick up the provided DTB in /etc.

### Fork board-support packages

In order to properly support the i.MX8 including all of its multimedia capabilities, many custom debs that are not part of Debian have been created. These include an optimized kernel, the Vivante GPU userspace, gstreamer plugins and many more. There are 2 ways for getting the package sources:

1. use apt-get source, e.g.: `apt-get source linux-image-5.4.y-imx8-sr`

2. browse the [SolidRun github](https://github.com/SolidRun), and the old [packaging organization](https://github.com/mxOBS)

All of our packages can be built by invoking dpkg-buildpackage directly, or through git-buildpackage. If there are specific questions regarding packaging of customizations please contact us.

## Pure Debian (upstream)

Our long-term goal is enabling as much of our hardware upstream as part of Debian where feasible. Success is highly dependent on the efforts of the general community around the i.MX8M SoCs, as well as the amount of proprietary blobs involved. At this point no support for the SolidRun i.MX8M boards is present in Debian.
