## Overview
As a proof of concept and for prototyping purposes we provide the option to run Debian on Armada 38x based devices. Please note that our images are not pure Debian - we made changes where necessary to enable our hardware.

## Device Support Matrix

| Release | Clearfog base | Clearfog Pro | Clearfog GTR |
| --- | --- | --- | --- |
| 10 Buster  ([images.solid-build.xyz](https://images.solid-build.xyz/A38X/Debian/)) | Yes | Yes | Yes |
|  9 Stretch ([images.solid-build.xyz](https://images.solid-build.xyz/A38X/Debian/)) | Yes | Yes | No |
|  8 Jessie  ([images.solid-build.xyz](https://images.solid-build.xyz/A38X/Debian/)) | Yes | Yes | No |
||||
| 10 Buster  ([debian.org](https://www.debian.org/)) | Yes | Yes | No |
|  9 Stretch ([debian.org](https://www.debian.org/)) | Yes | Yes | No |
|  8 Jessie  ([debian.org](https://www.debian.org/)) | No  | No  | No |

## Reference Images
Readily usable images of Debian are available at [images.solid-build.xyz](https://images.solid-build.xyz/A38X/Debian/).
They are intended to be used with any block storage device, and **do not come with a boot-loader** Please refer to our [A38X U-Boot page](https://developer.solid-run.com/knowledge-base/a388-u-boot/) for installation instructions.

**Default username and password are `debian` and `debian`** - with sudo privileges.

Using a tool of choice our images can be decompressed and written to a microSD card. We suggest [etcher.io](https://www.balena.io/etcher/) which takes care of the decompression by itself.
Alternatively an image can be written to an arbitrary drive on a Unix system:
```no-highlight
xzcat sr-a38x-debian-stretch-20180406.img.xz | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
```

## Customizing the Reference Images

The debian images are produced from a custom build system. The sources are available on [github](https://github.com/mxOBS/imagebuilder). To add software packages, configuration files or any other modifications: Look at **configs/sr-a38x-debian-stretch.inc**

    # How to build the image:
    ./mktarball.sh configs/sr-a38x-debian-stretch.inc
    ./mkimage.sh sr-a38x-debian-stretch.tar 1000M

## Pure Debian (upstream)

### Getting the Files

All files required are available on the [download page for buster](https://cdimage.debian.org/debian-cd/current/armhf/iso-cd/) and [download page for debian-installer](http://ftp.debian.org/debian/dists/buster/main/installer-armhf/current/images/):

- hd-media (other images → armhf → hd-media): [hd-media.tar.gz](http://ftp.debian.org/debian/dists/buster/main/installer-armhf/current/images/hd-media/hd-media.tar.gz)
- ISO (CD → armhf):
   - [netinstall](https://cdimage.debian.org/debian-cd/current/armhf/iso-cd/debian-10.0.0-armhf-netinst.iso)
   - [xfce](https://cdimage.debian.org/debian-cd/current/armhf/iso-cd/debian-10.0.0-armhf-xfce-CD-1.iso)

### Preparing the block-device

- Unpack hd-media.tar.gz to a partition on the drive
- Copy the downloaded ISO to a (/the same) partition on the drive

### Add U-Boot (optional)

U-Boot for the Clearfog devices is not part of Debian! That means it needs to be installed and managed seperately.

If the installation media is a microSD, then it can be wise to now install U-Boot to that card by following our instructions on the [U-Boot page](https://developer.solid-run.com/knowledge-base/a38x-u-boot/).

Otherwise U-Boot has to be loaded via UART or be already available on one of eMMC, microSD, SPI Flash and SSD.

**Warning: If U-Boot is installed on the same disk that debian will be installed to, it may get overridden! Safe locations for U-Boot are SPI Flash and the boot partitions of eMMC.**

### Add a preseed.cfg (optional)

A preseed file can be used to fully automate the installation. The Debian project maintains a sample for its current stable release at https://www.debian.org/releases/stable/example-preseed.txt.

Below is a sample for installing Buster to an M.2 SSD:

    # Localization
    d-i debian-installer/locale select en_GB

    # Networking
    d-i netcfg/choose_interface select eth0
    d-i netcfg/get_hostname string clearfog
    d-i netcfg/get_domain string unassigned-domain

    # Debian Mirror
    d-i mirror/country string manual
    d-i mirror/http/hostname string deb.debian.org
    d-i mirror/http/directory string /debian
    d-i mirror/http/proxy string

    # Users and Passwords
    d-i passwd/root-login boolean false
    d-i passwd/user-fullname string Debian User
    d-i passwd/username string debian
    d-i passwd/user-password password debian
    d-i passwd/user-password-again password debian

    # Time
    d-i clock-setup/utc boolean true
    d-i time/zone string Europe/Berlin
    d-i clock-setup/ntp boolean true

    # Partitioning
    d-i partman-auto/disk string /dev/sda
    d-i partman-auto/method string regular
    d-i partman-auto/choose_recipe atomic
    d-i partman-lvm/device_remove_lvm boolean true
    d-i partman-md/device_remove_md boolean true
    d-i partman-partitioning/confirm_write_new_label boolean true
    d-i partman/choose_partition select finish
    d-i partman/confirm boolean true
    d-i partman/confirm_nooverwrite boolean true

    # Package Selection
    tasksel tasksel/first multiselect standard, ssh-server

    # Package Survey
    popularity-contest popularity-contest/participate boolean false

    # Exit Installer
    d-i finish-install/reboot_in_progress note

    # Install U-Boot (u-boot-clearfog-pro-sata.kwb must be placed on the usb drive right next to the preseed.cfg)
    # d-i preseed/late_command string dd if=/hd-media/u-boot-clearfog-pro-sata.kwb of=/dev/sda bs=512 seek=1 conv=sync

Another method for acquiring a preseed.cfg file is to run the installer by hand, then ask debconf for the settings that the installer had been using:

    sudo debconf-get-selections --installer > preseed.cfg

The preseed.cfg file should be placed on the installation drive next to the iso image. In addition the automatic install has to be explicitly enabled through the kernel commandline from the U-Boot console:

    setenv bootargs "auto=true file=/hd-media/preseed.cfg"
    # boot into installer, e.g. usb
    run bootcmd_usb0

### Starting the Installation

All that is left to do is attaching the block storage to the Clearfog board and powering it up. The text based installer will show up on the serial console if boot succeeds.

The boot order is controlled by the **boot_targets** U-Boot environment variable. By default it says:

1. scsi0
2. mmc0
3. usb0
4. pxe
5. dhcp

In case the installer isn’t started automatically because an existing system is found and started first, booting from the installer drive can be forced by invoking the corresponding boot command on the U-Boot console:

    # for USB
    run bootcmd_usb0
    # for microSD
    run bootcmd_mmc0
    # for SSD
    run bootcmd_scsi0

## Known Issues

### EXPKEYSIG on repo.solid-build.xyz

Up to April 2018 we did not have a facility in place to update our repository signing key. While the key has been renewed on our build server, it **did expire** on any images from before October 22th 2017.

You know that you are affected when apt-get update shows an error message such as:

    debian@clearfog:~$ sudo apt update
    ...
    Err:6 https://repo.solid-build.xyz/debian/stretch/bsp-imx6 ./ Release.gpg
      The following signatures were invalid: EXPKEYSIG A86C36D7E45C02CD BSP:IMX6 OBS Project <BSP:IMX6@mxobs>
    ...
    W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: https://repo.solid-build.xyz/debian/stretch/bsp-imx6 ./ Release: The following signatures were invalid: EXPKEYSIG A86C36D7E45C02CD BSP:IMX6 OBS Project <BSP:IMX6@mxobs>
    W: Failed to fetch https://repo.solid-build.xyz/debian/stretch/bsp-imx6/./Release.gpg  The following signatures were invalid: EXPKEYSIG A86C36D7E45C02CD BSP:IMX6 OBS Project <BSP:IMX6@mxobs>
    W: Some index files failed to download. They have been ignored, or old ones used instead.

It is suggested that you install our solidrun-keyring package from our repos by hand. In the future this package will be used to roll out key extensions in the future. Navigate to [stretch](https://repo.solid-build.xyz/debian/stretch/bsp-any/all/) or [jessie](https://repo.solid-build.xyz/debian/jessie/bsp-any/all/); Find the deb by name of solidrun-keyring_*_all.deb and install. Now apt should once again be happy about our key.

### systemd[1]: Time has been changed

When the rtc has an invalid state, this error message can render debian unusable. In this case the rtc eneds to be reset. Enter u-boot console by pressing any key at the u-boot prompt, then reset the rtc twice and reboot:

    date reset
    date reset
    reset

## Clearfog Base / Pro eMMC Software Installation

Installing software on a ClearFog SOM with eMMC is a little tricky. You can not use the eMMC and the SD card simultaneously. The software for both initial boot, and the eMMC installation must be loaded from some other interface. Fortunately, the Armada 388 chip can boot from UART, so we can use that for initial boot.

This section describes a relatively painless procedure for installing the SolidRun provided Debian image on the eMMC. You will need to following items:

- USB storage device (Disk-on-Key), FAT formatted
- x86 PC running any flavor of Linux

Installation instructions follow.

1. Download an installation images and utilities archive from [here](https://developer.solid-run.com/wp-content/uploads/2018/10/clearfog-emmc-v3.tar.gz).
2. Connect your x86 PC host to the ClearFog UART console on the micro-USB
3. Copy the following files from the archive to the x86 PC:
   - kwboot
   - u-boot-clearfog-base-uart.kwb
4. Copy the following files from the archive to the USB storage device:
   - u-boot-clearfog-base-mmc.kwb
   - zImage
   - armada-388-clearfog.dtb
5. Create a directory named **extlinux** in the USB storage device
6. Copy the file **extlinux.conf** from the archive into the **extlinux** directory
7. Copy the latest Debian image (**.img.\*z** suffix) from [here](https://images.solid-build.xyz/A38X/Debian/) to the USB storage device
8. Set the Clearfog boot select DIP switches to UART boot:
   - For Clearfog Pro set to 11110
   - For Clearfog Base set to 01001
9. Plug the USB storage device into the Clearfog
10. Run the following command on the x86 PC:

        ./kwboot -t -b u-boot-clearfog-base-uart.kwb /dev/ttyUSB0

11. Power up the Clearfog
12. Wait a few minutes of the U-Boot image to download
13. Hit a key to stop autoboot
14. Configure the eMMC to boot from hardware boot partition:

        mmc partconf 0 1 1 0

15. Reset the RTC block

        date reset

16. Boot initial installation Linux image

        boot

17. Type `root` at the `buildroot login:` prompt
18. Mount the USB storage device

        mount /dev/sda1 /mnt

19. Install the bootloader

        echo 0 > /sys/block/mmcblk0boot0/force_ro
        dd if=/mnt/u-boot-clearfog-base-mmc.kwb of=/dev/mmcblk0boot0

20. Install the Debian filesystem

        xzcat /mnt/sr-a38x-debian-stretch-20180406.img.xz \
          | dd of=/dev/mmcblk0 bs=1M conv=fsync

21. Unmount the USB storage device

        umount /mnt

22. Power off the Clearfog
23. Set the DIP switches back to boot from SD/eMMC: 00111
24. Power on the Clearfog
25. Debian should boot to the `login:` prompt

## Clearfog GTR eMMC Software Installation

This section describes a procedure for installing the SolidRun provided Debian
image on the Clearfog GTR eMMC storage. You will need the following items:

- USB storage device (Disk-on-Key), FAT formatted

- x86 PC (64-bit) running any flavor of Linux

Installation instructions follow.

1. Download an installation images and utilities archive from
   [here](https://developer.solid-run.com/wp-content/uploads/2020/01/clearfog-gtr-emmc.tar.gz)

2. Connect your x86 PC host to the ClearFog GTR UART console on the micro-USB

3. Copy the following files from the archive to the x86 PC:

   - kwboot
   - u-boot-spl.kwb

4. Copy the following files from the archive to the USB storage device:

   - u-boot-spl.kwb
   - zImage
   - armada-385-clearfog-gtr-l8.dtb

5. Create a directory named extlinux in the USB storage device

6. Copy the file extlinux.conf from the archive into the extlinux directory

7. Copy the latest Debian image (`.img.*z` suffix) from
   [here](https://images.solid-build.xyz/A38X/Debian/) to the USB storage
   device

8. Set the Clearfog GTR boot select DIP switches to eMMC boot: 00111

9. Plug the USB storage device into the Clearfog

10. Run the following command on the x86 PC:

    ```
    ./kwboot -t -b u-boot-spl.kwb /dev/ttyUSB0
    ```

11. Power up the Clearfog GTR

12. Wait a few minutes of the U-Boot image to download

13. Hit a key to stop autoboot

14. Configure the eMMC to boot from hardware boot partition:

    ```
    mmc partconf 0 1 1 0
    ```

15. Boot initial installation Linux image:

    ```
    boot
    ```

16. Mount the USB storage device:

    ```
    mount /dev/sda1 /mnt
    ```

17. Install the bootloader:

    ```
    echo 0 > /sys/block/mmcblk0boot0/force_ro
    dd if=/mnt/u-boot-spl.kwb of=/dev/mmcblk0boot0
    ```

18. Install the Debian filesystem:

    ```
    xzcat /mnt/sr-a38x-debian-buster-20200114.img.xz \
      | dd of=/dev/mmcblk0 bs=1M conv=fsync
    ```

19. Unmount the USB storage device:

    ```
    umount /mnt
    ```

20. Reset or power cycle the Clearfog GTR

21. Debian should boot to the `login:` prompt
