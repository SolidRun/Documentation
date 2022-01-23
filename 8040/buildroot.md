## Introduction

Intention of this page is to provide the developers a quick page how to build mainline buildroot with MACHIATOBin u-boot, ATF and kernel with simple root filesystem.

## Grabbing source and building instructions

Getting the sources –

    git clone git://git.busybox.net/buildroot
    cd buildroot

Download [this mcbin minimal buildroot](https://images.solid-run.com/8040/Buildroot/buildroot_config_minimal.txt.gz) config file, gunzip it and place it buildroot directory as .config

Building the sources – Run –
make

An error will occur almost before building is finished. The reason is that the cloned ATF firmware doesn’t include Marvell DDR interface initializations, in order to fix run the following –

    git clone git@github.com:MarvellEmbeddedProcessors/mv-ddr-marvell.git output/build/arm-trusted-firmware-atf-v1.2-armada-17.02/drivers/marvell/mv_ddr/
    make

## Using the result images

    Boot from SPI while placing it in the first sector of the flash

        Boot from Micro SD while placing it in the second sector of the Micro SD

        Boot from eMMC while placing it in the first sector of either the first or second boot partitions

Boot from UART – Can be UART xmodem transmitted on a new board (or bricked). Note that if secure boot is disabled then the in-chip ROM bootrom will try to xmodem boot from UART0 before attempting the real requested boot device

output/images/Image – Kernel image with appended device tree and initramfs output/images/armada-8040-mcbin.dtb – Kernel device tree
Sample images

Using [this config file](https://images.solid-run.com/8040/Buildroot/buildroot_config.txt.gz) which is a config file that has much more target packages than the above, we get the following binaries – [flash-image.bin file](https://images.solid-run.com/8040/Buildroot/flash-image.bin.gz)

[mcbin dtb file](https://images.solid-run.com/8040/Buildroot/armada-8040-mcbin.dtb.gz)
[Kernel with initramfs](https://images.solid-run.com/8040/Buildroot/Image.gz)

In order to use them, download all the files and then gunzip them.

In order to run it, flash flash-image.bin into the SPI and then run it with the following –

    setenv bootargs console=ttyS0,115200; tftpboot 0x20000000 Image.8040-buildroot; tftpboot 0x1ff00000 armada-8040-mcbin_buildroot.dtb; booti 0x20000000 - 0x1ff00000
