# Debian 11 on Honeycomb Workstation

Disclaimer: Debian on Honeycomb is supported by the Debian community. We encourage engaging with them for support.

## Install U-Boot

To get started, minimal bootable disk images for microSD can be downloaded from [images.solid-run.com](https://images.solid-run.com/LX2k/lx2160a_build).
The latest disk image named `lx2160acex7_2000_700_????_8_5_2-*******.img.xz` with the first number lower or equal to the installed ram speed should generally work.

## Prepare Debian Install Media

Debian provides a special net-install medium to use with U-Boot. The commands below writes it to a fictitious `/dev/sdX` device. Make sure to replace X with the name or number of your destination usb flashdrive!

    wget https://deb.debian.org/debian/dists/bullseye/main/installer-arm64/current/images/netboot/SD-card-images/firmware.none.img.gz
    https://deb.debian.org/debian/dists/bullseye/main/installer-arm64/current/images/netboot/SD-card-images/partition.img.gz
    zcat firmware.none.img.gz partition.img.gz > | sudo dd of=/dev/sdx bs=4M conv=fsync

## Boot Debian Installer

Connect the serial console, power-on the device and interrupt automatic boot as the timeout prompt appears:

    ...
    fsl-mc: Booting Management Complex ... SUCCESS
    fsl-mc: Management Complex booted (version: 10.28.1, boot status: 0x1)
    Hit any key to stop autoboot:  0
    =>

Then stop the watchdog and enable the smmu bypass:

    => wdt dev watchdog@23a0000
    => wdt stop
    => setenv bootargs arm-smmu.disable-bypass=0

Finally, boot the install media:

    setenv boot_targets usb0
    # or alternatively microsd
    # setenv boot_targets mmc0
    boot

Continue going through the installation menus - and remove install media when it has completed.

## First Reboot

Since the bootable microSD card is still in use, the default boot-order should be changed for booting into the newly installed Debian system.
This is controlled through the boot_targets u-boot variable, and can be customised - e.g. to prefer eMMC over microSD:

    => print boot_targets
    boot_targets=usb0 mmc0 mmc1 scsi0 nvme0 dhcp
    => setenv boot_targets usb0 mmc1 mmc0 nvme0 scsi0
    => saveenv
    Saving Environment to MMC... Writing to MMC(0)... OK

Successive boots still require the mmu bypass enabled, so use below commands to make that option persistent:

    => setenv bootargs arm-smmu.disable-bypass=0
    => saveenv

Finally boot the new system by either pressing the reset button, or using the `boot` command.

## Tweaks

### Update Kernel

Through [Backports](https://backports.debian.org/Instructions/) Debian offers newer Linux releases for their stable distribution, e.g. at the time of writing - 5.16.
The following commands will install this new version:

    echo deb http://deb.debian.org/debian bullseye-backports main | sudo tee /etc/apt/sources.list.d/backports.list
    sudo apt-get update
    sudo apt-get install -t bullseye-backports linux-image-arm64
