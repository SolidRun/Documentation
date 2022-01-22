## Introduction
This page describes how to build, install and update the TianoCore EDK2 firmware for SolidRun Armada 8040-based devices.
It is currently available for the MacchiatoBin only, while we are working on extending it to the Clearfog GT 8k as well.

## Certified Binaries

Semihalf has produced an [ARM System Ready ES](https://developer.arm.com/architectures/system-architectures/arm-systemready/es) certified binary for the Macchiatobin Doubleshot board.
It is available for download from [their GitHub](https://github.com/Semihalf/edk2-platforms/wiki/MacchiatoBin-SH_1.0).

## Binaries

Based on the versions used for the certified binary, we have rebuilds from source available below:

- [MacchiatoBin Doubleshot](https://github.com/Josua-SR/armada-8040-uefi/releases/tag/sr-1.0)
- [MacchiatoBin Singleshot](https://github.com/Josua-SR/armada-8040-uefi/releases/tag/sr-1.0-ss)

## Manual Build

Source-code and instructions are available [here on GitHub](https://github.com/Josua-SR/armada-8040-uefi), with two branches: `develop` for the doubleshot, and `mcbinss` for the singleshot board variant.

## Install

### From UEFI

First, copy the firmware binary to a FAT filesystem on an internal or removable device, then:

- enter the UEFI Shell by pressing the ESC key boot, selecting "Boot Manager" -> "UEFI Shell", from within the UEFI Menu, and pressing ESC again to cancel automatic startup.

   Note: For headless systems, the serial console available on the microSD port can be used.

- find the filesystem device containing the firmware binary. This can be done by inspecting the Mapping table printed on screen, or by examing all filesystems one by one - e.g.:

       fs0:
       ls
       ...
       fs1:
       ls
       ...
       Directory of: FS5:\
       11/09/2019  13:49           2,730,940  uefi-mcbin-spi.bin

- finally install the firmware to SPI Flash with the fupdate command:

       fupdate uefi-mcbin-spi.bin spi

### From U-Boot

For installing the new firmware binary from U-Boot, follow the [instructions for writing U-Boot to SPI Flash](https://solidrun.atlassian.net/wiki/spaces/developer/pages/287178828/A8040+U-Boot+and+ATF#to-SPI-Flash)
