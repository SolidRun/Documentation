## Overview
As a proof of concept and for prototyping purposes we provide the option to run Debian on Armada 8040 based devices. Please note that our images are not pure Debian - we made changes where necessary to enable our hardware.

### Applicable Devices
- **MacchiatoBIN**
- **Clearfog GT 8k**

## Reference Images
Readily usable images of Debian Buster are available at [images.solid-build.xyz](https://images.solid-build.xyz/8040/).
They are intended to be used with a microSD card and ship with a suitable build of U-Boot already included.
**Default username and password are `debian` and `debian`** - with sudo privileges.

Using a tool of choice our images can be decompressed and written to a microSD card. We suggest [etcher.io](https://www.balena.io/etcher/) which takes care of the decompression by itself.
Alternatively an image can be written to an arbitrary drive on a Unix system:
```no-highlight
xzcat sr-8040-cf-gt-8k-debian-buster-20190619-sdhc.img.xz | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
```

### Other block storage
Functionally these images are also usable on **eMMC**, **USB** and **SATA**. In that case however U-Boot must be installed manually to start the system.
Please refer to [our article on U-Boot for 8040](https://developer.solid-run.com/knowledge-base/armada-8040-machiatobin-u-boot-and-atf/) for details.

## Pure Debian (upstream)
Running pure Debian is not yet possible due to a bug in Linux that was only recently fixed with 5.3 and backported to stable in 4.19.61. When Buster updates to 4.19.61 installing Debian as per the [handbook](https://www.debian.org/releases/stable/arm64/ch04s03.en.html#usb-copy-flexible) will likely be possible. However a number of features may not work properly and need more time for integration.
