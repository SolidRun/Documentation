## Introduction

This page describes how to build, install and update U-Boot for SolidRun Marvell-CN913x-based devices.

## Prebuilt Binaries

Usable firmware binaries are available inside the `u-boot` sub-folder of any [cn913x_build artifact](https://images.solid-run.com/CN913x/cn913x_build/).

There a variety of variants depending on SoC, and where U-Boot will be deployed:

- The SoC is indicated in the filename, e.g. `u-boot-cn9132-cex7-A-mmc:1:0.bin` is for the CN9132.
- The Carrier or Board follows the SoC name, e.g. `u-boot-cn9130-cf-base-mmc:1:2.bin` is for a Clearfog Base.
- The Boot Media follows the carrier or board name, e.g. `u-boot-cn9130-cf-pro-spi.bin` targets SPI flash.
  MMC variants specify 2 numbers:
  - number of mmc device (on Clearfog: 0 = eMMC, 1 = microSD)
  - number of spi partition (0 for data partition or microSD, 1 for boot0, 2 for boot1)
  e.g. `u-boot-cn9130-cf-base-mmc:0:2.bin` is for eMMC boot1.

## Select Boot-Device

Please refer to the [Boot-Select pages at our Developer Center](https://solidrun.atlassian.net/wiki/spaces/developer/pages/286490639/CN913x+Other+Articles) for configuration of the Boot-Select DIP Switches.

## Deploy

### From Linux

#### to microSD

First insert the target microSD into any computer running Linux and identify its canonical name in /dev, e.g. by reading through dmesg. Errors in this step **will** result in data loss!

The Boot ROM expects to find a bootable image at 512 bytes into the block device. Use dd for writing the previously compiled flash-image.bin to the designated location. In this example sdX is used as placeholder for the actual device name of your microSD on your system:

    dd if=u-boot-cn9130-cf-base-mmc:1:0.bin of=/dev/sdX bs=512 seek=4096 conv=sync

This process will also work on the device itself, if it has already booted into Linux.

#### to eMMC data partition


Since the eMMC is soldered to the board, this procedure has to be done on the device itself after booting into a Linux system first. The process is identical to microSD.

    dd if=u-boot-cn9130-cf-base-mmc:0:0.bin of=/dev/sdX bs=512 seek=4096 conv=sync

#### to eMMC bootY

Since the eMMC is soldered to the board, this procedure has to be done on the device itself after booting into a Linux system first. Please note that as with the eMMC data partition, the Boot ROM expects to find the bootable image at the start of the partition without any offset.

To avoid accidents, the boot partitions are write protected by default. This protection is easy enough to turn off:

    # for boot0:
    echo 0 | sudo tee /sys/block/mmcblk0boot0/force_ro

    # for boot1:
    echo 0 | sudo tee /sys/block/mmcblk0boot1/force_ro

Now the bootable image can be written to either boot partition with dd:

    # for boot0
    sudo dd if=u-boot-cn9130-cf-base-mmc:0:1.bin of=/dev/mmcblk0boot0 conv=fsync

    # for boot1
    sudo dd if=u-boot-cn9130-cf-base-mmc:0:2.bin of=/dev/mmcblk0boot1 conv=fsync

As a last step, the eMMC has to be configured for selecting the intended boot partition. This can be done on the U-Boot console with the `mmc partconf` command, or from Linux with the `mmc` application from mmc-utils:

    # from Linux (requires installing the mmc-utils package):
    # use boot0
    sudo mmc bootpart enable 1 0 /dev/mmcblk0
    # use boot1
    sudo mmc bootpart enable 2 0 /dev/mmcblk0

    # from U-Boot
    # use boot0
    mmc partconf 0 0 1 0
    # use boot1
    mmc partconf 0 0 2 0

### From U-Boot

#### to SPI Flash

This step requires U-Boot running on the target device first, e.g. loaded from microSD or UART. The flash-image.bin can then be loaded from either microSD, eMMC, USB or network, and finally written to the SPI flash.
This sample covers the easiest case where flash-image.bin is available on a fat formatted partition on a USB drive:

    # start USB stack
    usb start
    # scanning usb for storage devices... 1 Storage Device(s) found <-- indicates success

    # load u-boot binary to ram
    load usb 0:1 $kernel_addr_r u-boot-cn9130-cf-base-spi.bin
    # u-boot will indicate how many btes were read. Make sure to verify the number!

    # initialize spi flash
    sf probe

    # optionally erase
    sf erase 0 0x800000

    # finally write loaded file
    sf update $kernel_addr_r 0 0x$filesize

## Booting the board using UART

The CN913x can be booted through UART asa fall-back, when the configured boot media has no valid boot image. E.g. when the DIP switches are set to boot from SPI, but SPI flash is empty - the bootrom falls back to serial download.

This is mostly used for system manufacturing, unbricking etc ...

The tool provided by Marvell is available in our [cn913x_build repository on GitHub](https://github.com/SolidRun/cn913x_build/blob/master/tools/mrvl_uart.sh) along with [Marvell's documentation](https://github.com/SolidRun/cn913x_build/blob/master/tools/uart_boot.txt).
