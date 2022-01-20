## Overview
As a proof of concept and for prototyping purposes we provide the option to run Debian on Armada 8040 based devices. Please note that our images are not pure Debian - we made changes where necessary to enable our hardware.

### Applicable Devices
- **MacchiatoBIN Doubleshot**
- **Clearfog GT 8k**

## Reference Images

Readily usable images of Debian are available at [images.solid-run.com](https://images.solid-run.com/8040/Debian)!
They will work for any supported boot media, as long as U-Boot has previously been installed as per [the U-Boot page](https://solidrun.atlassian.net/wiki/spaces/developer/pages/287178828/A8040+U-Boot+and+ATF): USB, SATA, microSD and the eMMC data partition.
As a shortcut we also offer board-specific variants for microSD cards that include a suitable U-Boot binary.

**Default username and password are `debian` and `debian`** - with sudo privileges.

Using a tool of choice our images can be decompressed and written to a microSD card. We suggest [etcher.io](https://www.balena.io/etcher/) which takes care of the decompression by itself.
Alternatively an image can be written to an arbitrary drive on a Unix system by:
```no-highlight
xzcat sr-8040-debian-bullseye-20190619-mcbin.img.xz | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
```

### Customising

Since Bullseye we are using a custom tool built on [KIWI-NG](https://osinside.github.io/kiwi/) to generate the bootable disk images.
We make it available [here on our GitHub](https://github.com/SolidRun/debian-builder/tree/master) for general use. If you want to use it and have any questions, please contact support.

Previous images were created from a Shell Monster which we have published [here](https://github.com/mxOBS/imagebuilder), but do not recommend its use.

### Other block storage
Functionally these images are also usable on **eMMC**, **USB** and **SATA**. In that case however U-Boot must be installed manually to start the system.
Please refer to [our article on U-Boot for 8040](https://solidrun.atlassian.net/wiki/spaces/developer/pages/287178828/A8040+U-Boot+and+ATF) for details.

## Pure Debian with UEFI (upstream)

When opting for the new EDK2-based UEFI releases, Debian can be installed like on any common x86 pc by writing the official ISO to an optical or USB drive.
The UEFI menu and installer UI are accessible either via the serial console, or ith mouse and keyboard by adding a UEFI-capable GPU to the PCI-Express port.

## Pure Debian with U-Boot (upstream)

Running unmodified Debian is finally possible as per the release of version 11 called Bullseye!
This section outlines all required steps for booting the official installer on SolidRun 8040-based hardware.
For details and alternatives refer to [chapter 4](https://www.debian.org/releases/stable/arm64/ch04.en.html) in the [Debian GNU/Linux Installation Guide](https://www.debian.org/releases/stable/arm64/).

**Note that the installation steps below that U-Boot has already been installed, see [the U-Boot page](https://solidrun.atlassian.net/wiki/spaces/developer/pages/287178828/A8040+U-Boot+and+ATF) for details.**

1. Create bootable installer
   - network install

         wget http://ftp.debian.org/debian/dists/bullseye/main/installer-arm64/current/images/netboot/SD-card-images/firmware.none.img.gz
         wget http://ftp.debian.org/debian/dists/bullseye/main/installer-arm64/current/images/netboot/SD-card-images/partition.img.gz
         zcat firmware.none.img.gz partition.img.gz > installer.img

2. Write installer image block device

   We recommend using [etcher.io](https://www.balena.io/etcher/) for writing the `installer.img` file created in the previous step to a microSD or USB drive.

3. Perform Installation

   - Attach the bootable installer media from step 2 to the device
   - connect to the serial console
   - establish a network connection
   - power on and walk through the installation prompts

   Note: It is safe to overwrite the bootable installer media from step 2 during the installation.

4. Post-Installation Tweaks

   - (Re-) Install U-Boot if necessary

     If the boot media has been used as install target, U-Boot has to be reinstalled as documented on our [U-Boot page](https://solidrun.atlassian.net/wiki/spaces/developer/pages/287178828/A8040+U-Boot+and+ATF).

5. Known Issues:

   - Presence of PCI-E devices can make the installer hang during boot.

      Observed with an NVME on a m.2 adapter card ...

   - The single 1gbps port appears to not work at install time. Use one of the 10gbps interfaces as a work-around.
