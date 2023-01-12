# i.MX8DXL SoM Quick Start Guide

The following guide provides information about the first with i.MX8dxl SoM and its reference carrier.
It covers power-on, installation of our reference OS as well as some first steps on the console.

Revision and Notes

| Date | Owner | Revision | Notes |
| --- | --- | --- | --- |
| Jan 12, 2023 | | 0 | Draft |

## Hardware Setup

### Connections

- Unnamed Cable: Connect Carrier to "V2X Adapter" board.
- USB-A male to micro-USB male cable for console access. Connect to J5 on the "V2X Adapter" board, and the PC.
- USB-A male to USB-A male, preferably with 10kOhm resistor in VCC. Connect J1 on the "V2X Adapter" board, and the PC.
- Connect 12V DC power source to J10 on the "V2X Adapter" board.

TODO: Picture showing boards and cables, with labels.

### Boot Select

Ensure S1 DIP switch on the bottom of the carrier is configured to boot from eMMC:

| Switch             | 1 | 2 |
|--------------------|---|---|
| selected by eFuses | 0 | 0 |
| eMMC               | 0 | 1 |
| USB-OTG            | 1 | 0 |

### Console

Start an application for serial console - such as [PuTTY](https://www.putty.org/) or [tio](https://github.com/tio/tio). Configure it for baud rate 115200 and the COMx or ttyUSBy interface representing the USB-A to micro-USB console connection.

TODO: putty picture??

### Power On

After enabling the DC supply, messages from the bootloader should show up on the console.
When in doubt press the reset button on the bottom of the carrier (S1) once while wtaching the console to see whether the device is alive.
If the console is still quiet, likely U-Boot has not been programmed, or corrupted on the eMMC.
Please refer to the [developer documentation for our i.MX8DXL BSP](https://github.com/SolidRun/imx8dxl_build) for additional information and instructions on flashing U-Boot.

### Flash OS to eMMC

New SoMs ship with U-Boot preinstalled, but without an Operating System.
We provide reference images of Debian 11 to flash on eMMC.
Find and download the latest `emmc.img.xz` at [images.solid-run.com](https://images.solid-run.com/IMX8/imx8dxl_build).

Ensure the USB-A to USB-A cable is connected between the PC and the device. Then:

1. reset or power-on the device
2. Interrupt u-boot on the console at the timeout prompt for shell access:

       Hit any key to stop autoboot:  3

3. Start USB mass storage emulation for eMMC data partition:

       Hit any key to stop autoboot:  0
       => ums mmc 0
       UMS: LUN 0, dev mmc 0, hwpart 0, sector 0x0, count 0xe90e80
       \

4. The PC should now recognise a new USB drive. Flash the disk image using your tool of choice, e.g. [etcher.io](https://www.balena.io/etcher/).

   Note that etcher will automatically decompress the image file. With other tools make sure to extract the `.xz` file first!

5. On the U-Boot console, cancel usb mass storage emulation by pressing ctrl+c, then reboot or reset the device.

## First Steps with Debian reference system

### Login

After flashing the eMMC and booting into Linux, the serial console is the only accessible commandline.
Simply enter "root" and press return:

    Debian GNU/Linux 11 e7c450f97e59 ttyLP0

    e7c450f97e59 login: root
    Linux e7c450f97e59 5.15.5-00002-g0c527c0172f1-dirty #19 SMP PREEMPT Sun Aug 7 13:39:57 UTC 2022 aarch64

    The programs included with the Debian GNU/Linux system are free software;
    the exact distribution terms for each program are described in the
    individual files in /usr/share/doc/*/copyright.

    Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
    permitted by applicable law.

    root@e7c450f97e59:~#

### USB Networking

The system is preconfigured as a USB Ethernet Gadget. Via the same USB connection used for booting and flashing the eMMC, your computer should be detecting a generic usb network interface once Linux has booted. This allows e.g. for internet connection sharing, or simple peer to peer networking.
By default the system tries to acquire an IP address and DNS configuration via DHCP.

### Log-In via SSH

To log in via SSH, an ssh key must be installed first. Copy your favourite public key, e.g. from `~/.ssh/id_ed25519.pub`, into a new file in the root users home directory at `~/.ssh/authorized_keys`:

root@e7c450f97e59:~# mkdir .ssh
root@e7c450f97e59:~# cat > .ssh/authorized_keys << EOF
ssh-ed25519 AAAAinsertyour pubkey@here
EOF

### Expand Root Filesystem

After flashing the root filesystem is smaller than the eMMC. To utilize all space, resize both the rootfs partition - and then the filesystem:

1. inspect partitions:

   Using fdisk, view the current partitions. Take note of the start sector for partition 1!

       root@e7c450f97e59:~# fdisk /dev/mmcblk0

       Welcome to fdisk (util-linux 2.36.1).
       Changes will remain in memory only, until you decide to write them.
       Be careful before using the write command.


       Command (m for help): p
       Disk /dev/mmcblk0: 7.28 GiB, 7820083200 bytes, 15273600 sectors
       Units: sectors of 1 * 512 = 512 bytes
       Sector size (logical/physical): 512 bytes / 512 bytes
       I/O size (minimum/optimal): 512 bytes / 512 bytes
       Disklabel type: dos
       Disk identifier: 0xcc3ec3d4

       Device         Boot Start      End  Sectors  Size Id Type
       /dev/mmcblk0p1      49152  2690687  2641535  1.3G 83 Linux

       Command (m for help):

2. resize partition 1:

   Drop and re-create partition 1 at the same starting sector noted before, keeping the ext4 signature when prompted:

       Command (m for help): d
       Selected partition 1
       Partition 1 has been deleted.

       Command (m for help): n
       Partition type
          p   primary (0 primary, 0 extended, 4 free)
          e   extended (container for logical partitions)
       Select (default p): p
       Partition number (1-4, default 1): 1
       First sector (2048-15273599, default 2048): 49152
       Last sector, +/-sectors or +/-size{K,M,G,T,P} (49152-15273599, default 15273599):

       Created a new partition 1 of type 'Linux' and of size 7.3 GiB.
       Partition #1 contains a ext4 signature.

       Do you want to remove the signature? [Y]es/[N]o: N

       Command (m for help): p

       Disk /dev/mmcblk0: 7.28 GiB, 7820083200 bytes, 15273600 sectors
       Units: sectors of 1 * 512 = 512 bytes
       Sector size (logical/physical): 512 bytes / 512 bytes
       I/O size (minimum/optimal): 512 bytes / 512 bytes
       Disklabel type: dos
       Disk identifier: 0xcc3ec3d4

       Device         Boot Start      End  Sectors  Size Id Type
       /dev/mmcblk0p1      49152 15273599 15224448  7.3G 83 Linux

       Command (m for help): w
       The partition table has been altered.
       Syncing disks.

3. resize root filesystem:

   Linux supports online-resizing for the ext4 filesystem. Invoke `resize2fs` on partition 1 to do so:

       root@e7c450f97e59:~# resize2fs /dev/mmcblk0p1

## Additional Information

- [Developer documentation for reference image](https://github.com/SolidRun/imx8dxl_build)
