# Debian 12 on Honeycomb Workstation

Disclaimer: Debian on Honeycomb is supported by the Debian community. We encourage engaging with them for support.

## Install U-Boot (One-Time Setup)

To get started, minimal bootable disk images for microSD can be downloaded from [images.solid-run.com](https://images.solid-run.com/LX2k/lx2160a_build).
The latest disk image named `lx2160acex7_2000_700_????_8_5_2-*******.img.xz` with the first number lower or equal to the installed ram speed should generally work.

Decompress the `lx2160acex7_*.img.xz` file, then write the bootloader part to an SD card, e.g.:

    sudo dd if=/dev/zero bs=512 count=1 of=/dev/sdX
    sudo dd bs=512 seek=1 skip=1 count=131071 conv=fsync if=lx2160acex7_2000_700_2400_8_5_2-bae3e6e.img of=/dev/sdX

Configure the DIP switches for SD boot: `0 1 1 1 X` (0 = off, 1 = on, x = don't care)

As long as it is not overriden (e.g. by installing Debian to the Card), it can be used as bootloader.

Alternatively while first booting from this card, bootloader can be installed permanently to SPI flash on the CEX module:

### Install U-Boot to SPI Flash

1. Interrupt boot process at the timeout promp by pressing any key:

       fsl-mc: Booting Management Complex ... SUCCESS
       fsl-mc: Management Complex booted (version: 10.37.0, boot status: 0x1)
       Hit any key to stop autoboot:  0
       =>

2. Load boot-loader parts from sd-card

       mmc dev 0
       mmc read 0x81100000 0 0x20000

3. write boot-loader to spi flash

       sf probe
       sf erase 0 0x4000000
       sf update 0x81101000 0 0x20000
       sf update 0x81120000 0x20000 0x3FE0000

4. change DIP switches for SPI boot: `0 0 0 0 X` (0 = off, 1 = on, x = don't care)

5. remove sd-card, power-cycle device and confirm that u-boot is starting again (see same prompt as in step 1).

## Prepare Debian Install Media

Debian provides a special net-install medium compatible with U-Boot.
It can be found on the [Debian Website](https://www.debian.org/) by following "Other downloads", "Download an installation image", "A small installation image", "
Tiny CDs, flexible USB sticks, etc.", "arm64", "SD-card-images": https://deb.debian.org/debian/dists/bookworm/main/installer-arm64/current/images/netboot/SD-card-images/

The commands below can create a generic bootable disk at fictonal `/dev/sdX` block device (SD-Card or USB Flash-Drive).
Make sure to replace X with the name or number of your destination drive. *Carelessness in this step can lead to data loss!*

    wget https://deb.debian.org/debian/dists/bookworm/main/installer-arm64/current/images/netboot/SD-card-images/firmware.none.img.gz
    wget https://deb.debian.org/debian/dists/bookworm/main/installer-arm64/current/images/netboot/SD-card-images/partition.img.gz
    zcat firmware.none.img.gz partition.img.gz | sudo dd of=/dev/sdX bs=4M conv=fsync

## Boot Debian Installer

### Preparation (One-Time Setup)

Connect the serial console, power-on the device and interrupt automatic boot as the timeout prompt appears:

    ...
    fsl-mc: Booting Management Complex ... SUCCESS
    fsl-mc: Management Complex booted (version: 10.28.1, boot status: 0x1)
    Hit any key to stop autoboot:  0
    =>

Optionally clear all current settings:

    => env default -a

Ensure `fdtfile` variable includes `freescale/` prefix:

    => print fdtfile
    fdtfile=fsl-lx2160a-clearfog-cx.dtb
    => setenv fdtfile freescale/fsl-lx2160a-clearfog-cx.dtb

Enable the smmu bypass:

    => setenv bootargs arm-smmu.disable-bypass=0

Save these settings for future (re-)boots:

    => saveenv

IF setting were cleared in earlier step, use reset-button or power-cycle the unit now.

### Boot Debian Installer

As long as the bootloader is not overriden / reinstalled, the steps above
are required only a single time.
The steps below are required every time the debian installer is invoked,
first install and reinstall / repair.

Stop the watchdog:

    => wdt dev watchdog@23a0000
    => wdt stop

Boot the install media:

    setenv boot_targets usb0
    # or alternatively microsd
    # setenv boot_targets mmc0
    boot

Continue going through the installation menus - and remove install media when it has completed.

## First Reboot

In case there might be multiple media with bootable operating systems present at the same time,
e.g. on both SD-Card and eMMC, the default boot-order should be reviewed and customised.
This is controlled through the boot_targets u-boot variable, and can be customised - e.g. to prefer eMMC over microSD:

    => print boot_targets
    boot_targets=usb0 mmc0 mmc1 scsi0 nvme0 dhcp
    => setenv boot_targets usb0 mmc1 mmc0 nvme0 scsi0
    => saveenv
    Saving Environment to MMC... Writing to MMC(0)... OK

Finally boot the new system by either pressing the reset button, or using the `boot` command.

## Tweaks

### Enable Fan-Controller

If the system overheats at the default low fan-speed under load,
likely the fan-controller driver wasn't loaded automatically.
After loading the driver, fan-speed should dynamically follow cpu temperature:

    sudo modprobe amc6821

A bugfix has been submitted to the kernel: [hwmon: (amc6821) add of_match table](https://patchwork.kernel.org/project/linux-hwmon/patch/20240307-amc6821-of-match-v1-1-5f40464a3110@solid-run.com/)

### Enable SFP Ports

The SFP ports network devices (`eth*`) can be started manually after each (re-) boot using NXP's DPAA2 Management Utility [restool](https://github.com/nxp-qoriq/restool).

#### Patch Debian Kernel

Unfortunately Debian is missing an essential driver for the SerDes link between SoC and SFPs:

    CONFIG_PHY_FSL_LYNX_28G=m

A Debian Bug has already been opened: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1061117

As a temporary measure a patched version of Debian `6.5.0-0.deb12.4` is available [here](https://drive.google.com/file/d/1UTKVZW9vooaYw-bNgbJnCWAM4nGsOt1O/view?usp=sharing).
It is installed using the commands below:

```
sudo dpkg -i linux-image-6.5.0-0.deb12.4-arm64-unsigned_6.5.10-1~bpo12+1_arm64.deb
# success indicated by these messages:
flash-kernel: installing version 6.5.0-0.deb12.4-arm64
Generating boot script u-boot image... done.
Taking backup of boot.scr.
Installing new boot.scr.

# optionally to allow building custom kernel modules:
sudo apt-get install build-essential
sudo dpkg -i linux-kbuild-6.5.0-0.deb12.4_6.5.10-1~bpo12+1_arm64.deb linux-headers-6.5.0-0.deb12.4-common_6.5.10-1~bpo12+1_all.deb linux-headers-6.5.0-0.deb12.4-arm64_6.5.10-1~bpo12+1_arm64.deb
```

Once Debian integrated the changes, follow instructions below:

Upgrade Kernel via [backports](https://backports.debian.org/Instructions/), adding the missing drivers.

    apt-get install -t bookworm-backports linux-image-arm64

#### Install Restool

```
sudo apt-get install --no-install-recommends build-essential git pandoc
git clone https://github.com/nxp-qoriq/restool.git
cd restool
git reset --hard LSDK-21.08
make
sudo make install
```

#### Activate SFP Interfaces

Affected by [Debian Bug #1061117](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1061117)

Each SFP port is connected to a "dpmac" object managed by the network coprocessor.

To start all 4 SFPs, execute the commands below in order. They successively create new interfaces `eth1`, `eth2`, `eth3`, `eth4`:

    sudo ls-addni dpmac.7
    sudo ls-addni dpmac.8
    sudo ls-addni dpmac.9
    sudo ls-addni dpmac.10

### workaround for "task cryptomgr_test:493 blocked for more than 241 seconds" kernel log spam

Something is broken in Linux 6.5 for cryptomgr module tests, see e.g. [random form conversation about this issue](https://community.mnt.re/t/changes-introduced-by-kernel-6-5-rc7-1-exp1-reform20230831t205634z1/1651/10).

These tests can be disabled by adding kernel argument `cryptomgr.notests`:

1. Edit `/etc/default/flash-kernel`,
   update `LINUX_KERNEL_CMDLINE_DEFAULTS` variable to include `cryptomgr.notests`, e.g.:

   ```
   LINUX_KERNEL_CMDLINE="quiet"
   LINUX_KERNEL_CMDLINE_DEFAULTS="cryptomgr.notests"
   ```

2. Regenerate debian boot-script:

   ```
   sudo flash-kernel
   Using DTB: freescale/fsl-lx2160a-clearfog-cx.dtb
   Installing /etc/flash-kernel/dtbs/fsl-lx2160a-clearfog-cx.dtb into /boot/dtbs/6.5.0-0.deb12.4-arm64/freescale/fsl-lx2160a-clearfog-cx.dtb
   Taking backup of fsl-lx2160a-clearfog-cx.dtb.
   Installing new fsl-lx2160a-clearfog-cx.dtb.
   flash-kernel: installing version 6.5.0-0.deb12.4-arm64
   Generating boot script u-boot image... done.
   Taking backup of boot.scr.
   Installing new boot.scr.
   ```
