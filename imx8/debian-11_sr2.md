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

- [i.MX8MM Hummingboard Pulse, microSD bootable](https://images.solid-build.xyz/IMX8/Debian/sr-imx8-debian-bullseye-20201123-cli-imx8mm-sdhc-hummingboard-pulse.img.xz)
- [i.MX8MP HummingBoard Pulse, microSD bootable](https://images.solid-build.xyz/IMX8/Debian/sr-imx8-debian-bullseye-20201123-cli-imx8mp-sdhc-hummingboard-pulse.img.xz)
- [i.MX8MQ HummingBoard Pulse, microSD bootable](https://images.solid-build.xyz/IMX8/Debian/sr-imx8-debian-bullseye-20201123-cli-imx8mq-sdhc-hummingboard-pulse.img.xz)

# Documentation

## Install

All images are designed for raw deployment byte by byte (**not as a file**) to block storage such as microSD cards. Several tools can be used, including `dd`, `win32diskimager` and [etcher.io](https://etcher.io/). Note that care must be taken to decompress the image file for the first 2, while *etcher.io* can also handle the compressed image.

### Install to eMMC

The eMMC is accessible from the running system as `/dev/mmcblk2`. Install the
Debian software image to eMMC by writing the image directly to `/dev/mmcblk2`:

	xzcat sr-imx8-debian-buster-20191120-cli-imx8mq-sdhc.img.xz | dd of=/dev/mmcblk2 bs=4k conv=fdatasync

Set SW3 DIP switches to boot from eMMC as documented in the [HummingBoard
Pulse Boot
Select](https://developer.solid-run.com/knowledge-base/hummingboard-pulse-boot-select/)
article.
Also make sure to remove any microSD that contains the **same** image that was flashed to eMMC, as it can cause conflicts in rootfs identification.

## Get Started

Once you are greeted by a login prompt, the default username and password are both "debian". For security reasons there is **no** root password! If you really need one, you can run `sudo passwd root` to set your own.

## Known Issues

### mini-PCIe by default not functional on i.MX8MQ HummingBoard Pulse

In default configuration of Debian images, the mini-PCIe slot on the HummingBoard Pulse is not functional. When combined with a microSOM that has WiFi - the corresponding pcie controller is blocked and mini-PCIe can not be used in the first place.

For i.MX8MQ SOMs **without** WiFi however, the port can be enabled on images dated *Sept. 14. 2020* or later, by using the serial console exposed through the microUSB port with a serial terminal emulator of choice, such as [tio](https://tio.github.io/) or [putty](https://www.putty.org/):

1. breaking into U-Boot (press any key before the 3 seconds timeout prompt)


       U-Boot SPL 2018.11-g768f3f3 (Aug 04 2020 - 10:24:09 +0000)
       PMIC:  PFUZE100 ID=0x10
       Normal Boot
       Trying to boot from MMC2
       
       
       U-Boot 2018.11-g768f3f3 (Aug 04 2020 - 10:24:09 +0000)
       
       CPU:   Freescale i.MX8MQ rev2.0 at 1000 MHz
       Reset cause: POR
       Model: SolidRun i.MX8MQ HummingBoard Pulse
       DRAM:  1 GiB
       MMC:   FSL_SDHC: 0, FSL_SDHC: 1
       Loading Environment from MMC... *** Warning - bad CRC, using default environment
       
       In:    serial
       Out:   serial
       Err:   serial
       Net:   
       Warning: ethernet@30be0000 (eth0) using random MAC address - d2:63:b4:50:9c:21
       eth0: ethernet@30be0000
       Hit any key to stop autoboot:  0
       => 

2. choosing the devicetree file for SoMs without WiFi

       => setenv fdtfile imx8mq-hummingboard-pulse-nowifi.dtb
       => saveenv
       Saving Environment to MMC... Writing to MMC(1)... OK

3. booting ahead

       => boot

Note: These changes are permanent only to this particular installation of U-Boot - and might revert on rtc reset or change to other images. We are working on a way to autodetect the SoM - but at this point manual selection is still required :(

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
