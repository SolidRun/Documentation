# SolidRun Debian 11 - Release 8

## Summary

- Upstream Release: Debian 11 (testing)
- SolidRun Release: 8
- Hardware
  - i.MX8MM Hummingbord Pulse
  - i.MX8MP CuBox-M
  - i.MX8MP Hummingbord Pulse
  - i.MX8MQ Hummingbord Pulse
- Features: [i.MX8M: **M**ini|**P**lus|**Q**uad]
  - Ports:
    - microSD [M|P|Q]
    - Ethernet
      - primary interface [M|P|Q]
      - secondary interface [~~M~~|~~P~~|~~Q~~]
    - SoM integrated WiFi+Bluetooth [M|P|~~Q~~]
    - 2x USB-3.0 Type A [M|P|Q]
    - HDMI [~~M~~|~~P~~|Q]
    - microHDMI [M|P|~~Q~~]
    - eMMC [M|P|Q]
    - 3.5mm stereo-out and microphone-in jack [M|P|Q]
  - Multimedia:
    - OpenCL 1.2 [~~M~~|P|Q]
    - OpenGL-ES 2.0 [M|P|Q]
    - OpenGL-ES 3.1 [~~M~~|P|Q]
    - GStreamer HW-Accelerated Video Decoder
      - VP9 []
      - H.264 []
      - H.265 []
    - ALSA Audio Playback
      - HDMI [~~M~~|P|Q]
      - 3.5mm jack [M|P|Q]
- Major Components:
  - [Linux 5.4.47](https://github.com/SolidRun/linux-stable/tree/linux-5.4.y-imx8)
  - NXP Graphics SDK 6.4.3.p0

## Download

- [i.MX8MM Hummingboard Pulse, microSD bootable](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-bullseye-20210706-cli-imx8mm-sdhc-hummingboard-pulse.img.xz)
- [i.MX8MP CuBox-M, microSD bootable](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-bullseye-20210706-cli-imx8mp-sdhc-cubox-pulse.img.xz)
- [i.MX8MP HummingBoard Pulse, microSD bootable](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-bullseye-20210706-cli-imx8mp-sdhc-hummingboard-pulse.img.xz)
- [i.MX8MQ HummingBoard Pulse, microSD bootable](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-bullseye-20210706-cli-imx8mq-sdhc-hummingboard-pulse.img.xz)

# Documentation

## Install

All images are designed for raw deployment byte by byte (**not as a file**) to block storage such as microSD cards. Several tools can be used, including `dd`, `win32diskimager` and [etcher.io](https://etcher.io/). Note that care must be taken to decompress the image file for the first 2, while *etcher.io* can also handle the compressed image.

### Install to eMMC

The eMMC is accessible from the running system by varying names depending on the particular SoC. It can be identified by the special partitions such as boot0: e.g. if `/dev/mmcblk2boot0` exists, /dev/mmcblk2 is the eMMC. Install the
Debian software image to eMMC by writing the image directly to the data partition:

	xzcat sr-imx8-debian-buster-20191120-cli-imx8mq-sdhc.img.xz | dd of=/dev/mmcblk2 bs=4k conv=fdatasync

Set SW3 DIP switches to boot from eMMC as documented in the [HummingBoard
Pulse Boot
Select](https://solidrun.atlassian.net/wiki/spaces/developer/pages/287343073/HummingBoard+Pulse+and+Ripple+Boot+Select)
article.
Also make sure to remove any microSD that contains the **same** image that was flashed to eMMC, as it can cause conflicts in rootfs identification.

## Usage Hints

### OpenCL

    sudo apt install imx-gpu-viv-demos
    /opt/viv_samples/cl11/UnitTest/clinfo

### OpenGL-ES

- glmark2

  Benchmark for OpenGL-ES 2.0 - available [here on github](https://github.com/glmark2/glmark2).
  Instructions for building and running a compatible fork from source:

      sudo apt install build-essential git imx-gpu-viv-fb-dev imx-gpu-viv-dev libjpeg-dev libpng-dev pkg-config python
      git clone -b fbdev https://github.com/Josua-SR/glmark2.git
      cd glmark2
      ./waf configure --with-flavors=fbdev-glesv2
      ./waf build -j4
      sudo ./waf install

      glmark2-es2-fbdev

### GStreamer Examples

    sudo apt install gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-alsa gstreamer1.0-tools gstreamer1.0-imx

    wget https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_1080p_h264.mov
    gst-launch-1.0 playbin audio-sink="alsasink device=dmix:CARD=wm8904audio" uri=file://$PWD/big_buck_bunny_1080p_h264.mov

### ALSA Examples

    sudo apt install vorbis-tools
    wget https://github.com/KDE/amarok/raw/master/data/first_run_jingle.ogg
    ogg123 -d alsa -o dev:dmix:CARD=wm8904audio first_run_jingle.ogg

## Get Started

Once you are greeted by a login prompt, the default username and password are both "debian". For security reasons there is **no** root password! If you really need one, you can run `sudo passwd root` to set your own.

## Known Issues

### mini-PCIe not functional on i.MX8MQ

This is a problem with NXPs 5.4 kernel release, which does not properly support pcie on the i.MX8MQ SoC.

## Customize

### Using custom Device-Tree Blobs

We are trying to follow Debian design patterns where possible especially in the boot process. The *flash-kernel* application is used for installing DTBs to /boot as well as creating a boot-script for u-boot to load kernel, ramdisk and dtb.

Using a custom DTB here is as simple as putting it in **/etc/flash-kernel/dtbs** and rerunning `flash-kernel`. From this point onwards whenever an update to the kernel, or parts of the ramdisk occurs *flash-kernel* will automatically pick up the provided DTB in /etc.

### Fork board-support packages

In order to properly support the i.MX8 including all of its multimedia capabilities, many custom debs that are not part of Debian have been created. These include an optimized kernel, the Vivante GPU userspace, gstreamer plugins and many more. There are 2 ways for getting the package sources:

1. use apt-get source, e.g.: `apt-get source linux-image-5.4.y-imx8-sr`

2. browse the [SolidRun github](https://github.com/SolidRun), and the old [packaging organization](https://github.com/mxOBS)

All of our packages can be built by invoking dpkg-buildpackage directly, or through git-buildpackage. If there are specific questions regarding packaging of customizations please contact us.

## Pure Debian (upstream)

Our long-term goal is enabling as much of our hardware upstream as part of Debian where feasible. Success is highly dependent on the efforts of the general community around the i.MX8M SoCs, as well as the amount of proprietary blobs involved. At this point no support for the SolidRun i.MX8M boards is present in Debian.
