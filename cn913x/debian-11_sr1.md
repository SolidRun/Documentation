## Overview
As a proof of concept and for prototyping purposes we provide the option to run Debian on Octeon TX2 CN913x based devices.
Please note that our images are not pure Debian - we made changes where necessary to enable our hardware.

### Applicable Devices

- **CN9130 Clearfog Base**
- **CN9130 Clearfog Pro**
- **CN9130 COM Express 7**
- **CN9131 COM Express 7**
- **CN9132 COM Express 7**

## Download

[CN913x Debian 11 SR Release 1](https://images.solid-run.com/CN913x/Debian/sr-cn913-debian-bullseye-20220322.img.xz)

This image comes without U-Boot! Devices produced starting from April 1. 2022 ship with a suitable version preinstalled to SPI Flash.
For earlier units please refer to both sections below:

- [CN913x U-Boot Documentation](https://github.com/SolidRun/documentation/cn913x/u-boot.md) on how to install U-Boot to any of the supported boot media
- [CN913x TLV EEPROM Documentation](https://github.com/SolidRun/documentation/tlv-eeprom.md) on programming the Carrier and SoM EEPROMs for device identification.

  For proper operation of Debian it is sufficient to program only the `TLV_CODE_PART_NUMBER` entry with the **long SKU** (SoM stickers have the shortened version).

## Install

Using a tool of choice the image can be decompressed and written to either a microSD card or USB flash-drive. We suggest [etcher.io](https://www.balena.io/etcher/) which also takes care of the decompression by itself.
Alternatively an image can be written to arbitrary drives on any Unix system by: `xzcat sr-cn913-debian-bullseye-20220312.img.xz | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress`

## Get Started

Once you are greeted by a login prompt, the **default username and password are both `debian`**.
For security reasons there is **no** root password! If you really need one, you can run `sudo passwd root` to set your own.

## Customising

Since Bullseye we are using a custom tool built on [KIWI-NG](https://osinside.github.io/kiwi/) to generate the bootable disk images.
We make it available [here on our GitHub](https://github.com/SolidRun/debian-builder/tree/master) for general use. If you want to use it and have any questions, please contact support.
