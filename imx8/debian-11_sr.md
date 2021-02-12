# SolidRun Debian 11 - Release 1

## Summary

- Upstream Release: Debian 11 (testing)
- SolidRun Release: 1
- Hardware
  - i.MX8MM Hummingbord Pulse
  - i.MX8MQ Cubox Pulse
  - i.MX8MQ Hummingbord Pulse
- Features:
  - OpenCL (only i.MX8MQ)
  - OpenGL-ES 1.0, 1.1, 2.0, 3.0
    - KMS
    - Wayland
  - Video Playback with GStreamer
    - H.264
- Major Components:
  - [Linux 4.19.35](https://github.com/SolidRun/linux-stable/tree/linux-4.19.y-imx8)
  - NXP Graphics SDK 6.4.0.p1

## Download

- [i.MX8MM Hummingboard Pulse, microSD bootable](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-bullseye-20201020-cli-imx8mm-sdhc-hummingboard-pulse.img.xz)
- [i.MX8MQ Cubox Pulse, microSD bootable](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-bullseye-20201020-cli-imx8mq-sdhc-cubox-pulse.img.xz)
- [i.MX8MQ HummingBoard Pulse, microSD bootable](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-bullseye-20201020-cli-imx8mq-sdhc-hummingboard-pulse.img.xz)

# Documentation

## Install

All images are designed for raw deployment byte by byte (**not as a file**) to block storage such as microSD cards. Several tools can be used, including `dd`, `win32diskimager` and [etcher.io](https://etcher.io/). Note that care must be taken to decompress the image file for the first 2, while *etcher.io* can also handle the compressed image.

### Install to eMMC

The eMMC is accessible from the running system as `/dev/mmcblk2`. Install the
Debian software image to eMMC by writing the image directly to `/dev/mmcblk2`:

	xzcat sr-imx8-debian-buster-20191120-cli-imx8mq-sdhc.img.xz | dd of=/dev/mmcblk2 bs=4k conv=fdatasync

Set SW3 DIP switches to boot from eMMC as documented in the [HummingBoard
Pulse Boot
Select](https://developer.solid-run.com/knowledge-base/hummingboard-pulse-boot-select/)
article.

## Get Started

Once you are greeted by a login prompt, the default username and password are both "debian". For security reasons there is **no** root password! If you really need one, you can run `sudo passwd root` to set your own.

**For Cubox Pulse however the DeviceTree has to be selected on the U-Boot Shell:**

Connect to the serial console with a terminal emulator of choice, then power on the device and wait for the line that says `Hit any key to stop autoboot: 3` – then immediately press any key, to abort! The terminal will drop to the U-Boot Shell as follows:

    U-Boot SPL 2018.11-00078-g0dd51748c2a (Dec 16 2018 - 18:35:18 +0100)
    PMIC:  PFUZE100 ID=0x10
    Normal Boot
    Trying to boot from MMC2
    NOTICE:  Configureing TZASC380
    NOTICE:  BL31: v1.6(release):v1.6-110-g0eb2df45
    NOTICE:  BL31: Built : 13:56:07, Nov 29 2018
    NOTICE:  sip svc init
    U-Boot 2018.11-00078-g0dd51748c2a (Dec 16 2018 - 18:35:18 +0100)
    CPU:   Freescale i.MX8MQ rev2.0 at 1000 MHz
    Reset cause: POR
    Model: SolidRun i.MX8MQ HummingBoard Pulse
    DRAM:  3 GiB
    MMC:   FSL_SDHC: 0, FSL_SDHC: 1
    Loading Environment from MMC... OK
    In:    serial
    Out:   serial
    Err:   serial
    Net:   
    Error: ethernet@30be0000 address not set.
    Error: ethernet@30be0000 address not set.
    eth-1: ethernet@30be0000
    Hit any key to stop autoboot:  0 
    =>

Now is the time to override the name of device-tree for Cubox Pulse:

    setenv fdtfile imx8mq-cubox-pulse.dtb
    saveenv

This setting is permanent as long as the boot sectors of this particular microSD aren’t overridden, e.g. by writing a new image to it.
Reboot the device by unplugging power, and let it boot up into Debian.

## Accelerated OpenGL-ES

The drivers for the Vivante GPU that is part of i.MX8 SoCs are available as packages from our repository to be installed with apt. There are variants for Framebuffer, Wayland ~~and X11~~:

- Framebuffer:
  - runtime: `imx-gpu-viv imx-gpu-viv-fb libgbm-dev`
  - development: `imx-gpu-viv-dev imx-gpu-viv-fb-dev libgbm-dev`
- Wayland:
  - runtime: `imx-gpu-viv imx-gpu-viv-wl libgbm-dev`
  - development: `imx-gpu-viv-dev imx-gpu-viv-wl-dev libgbm-dev`
- ~~X11 (TBD)~~

When all variants are installed side by side, the default is selected through `update-alternatives` by configuring the `vivante-gal` link group:

    sudo update-alternatives --config vivante-gal

### Demos
- Vivante Demos
  The NXP Graphics SDK ships with a few sample applications for OpenGL and OpenCL:

      apt install imx-gpu-viv-demos
      /opt/viv_samples/cl11/UnitTest/clinfo
      /opt/viv_samples/es20/vv_launcher/vv_launcher
      /opt/viv_samples/tiger/tiger
      # ...

- eglinfo

  A small application for printing version and feature information of the active EGL and OpenGl-ES implementation. It is available [here on github](https://github.com/dv1/eglinfo) and installable through apt from our bsp repository:

      apt install eglinfo-fb
      # or any of eglinfo-wl eglinfo-x11

- glmark2

  Benchmark for OpenGL-ES 2.0 - available [here on github](https://github.com/glmark2/glmark2).
  Instructions for building and running from source:

      sudo apt install build-essential git imx-gpu-viv-fb-dev imx-gpu-viv-dev libjpeg-dev libpng-dev libwayland-dev libx11-dev pkg-config python
      git clone -b fbdev https://github.com/Josua-SR/glmark2.git
      cd glmark2
      ./waf configure --with-flavors=drm-glesv2,wayland-glesv2,x11-glesv2
      ./waf build -j4
      sudo ./waf install

      glmark2-es2-drm # on Framebuffer
      #glmark2-es2-wayland # on Wayland
      #glmark2-es2 # on X

- [gbm_es2_demo](https://github.com/ds-hwang/gbm_es2_demo)

- QT5 cube demo

       sudo apt install libqt5gui5-gles qtbase5-gles-dev qt5-eglfs-integration-vivante qt5-eglfs-integration-vivante-wayland
       git clone https://code.qt.io/qt/qtbase.git
       cp -r qtbase/examples/opengl/cube ./qt5-cube
       cd qt5-cube

       export QT_SELECT=5
       export QMAKE_LIBS_EGL=/usr/lib/galcore/libEGL.so QMAKE_LIBS_OPENGL_ES2=/usr/lib/galcore/libGLESv2.so
       qmake QMAKE_LIBS_OPENGL_ES2=/usr/lib/galcore/libGLESv2.so
       make
       env QT_QPA_PLATFORM=eglfs QT_QPA_EGLFS_INTEGRATION=eglfs_viv ./cube

## Accelerated Video Decoding and Playback

While directly using the VPU libraries provided by NXP is possible, that use-case goes beyond the scope of this document. Instead we are using the GStreamer 1.0 plugins for i.MX platforms to make use of those acceleration blocks in the SoC.

The plugins are available in our repos and installed by `apt install gstreamer1.0-imx`

Note that it is essential to configure GStreamer for using OpenGL-ES.

- On Framebuffer:

       export GST_GL_PLATFORM=egl GST_GL_API=gles2 GST_GL_WINDOW=gbm

- On Wayland: *TBD*

- On X11: *TBD*

### Examples

The examples below depend on a number of additional gstreamer elements and utilities:

    sudo apt install gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-alsa gstreamer1.0-tools
    sudo apt install gstreamer1.0-imx

- automatic with playbin (720p)

       gst-launch-1.0 playbin3 uri=http://distribution.bbb3d.renderfarming.net/video/mp4/big_buck_bunny_720p_surround.avi
       # for wayland, append video-sink=waylandsink

- automatic with playbin (1080p)

       gst-launch-1.0 playbin3 uri=http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_30fps_normal.mp4
       # for wayland, append video-sink=waylandsink

## Wayland

While a special release of Weston by NXP is available, the default weston package in Debian can be used instead with the drm backend.

Installation including the vivante OpenGL implementation is as simple as

    sudo apt install imx-gpu-viv imx-gpu-viv-wl weston

Then, to start - use weston-launch on a terminal session (**not ssh or uart!**)

    weston-launch

### X11

Abandoned. NXP does not officially support using Xorg on the i.MX8M SoCs - causing a gap in functional xorg drivers required for DRI and GLX.

## Known Issues

### mini-PCIe by default not functional on HummingBoard Pulse

In default configuration of Debian images, the mini-PCIe slot on the HummingBoard Pulse is not functional. When combined with a microSOM that has WiFi - the corresponding pcie controller is blocked and mini-PCIe can not be used in the first place.

For i.MX8MQ SOMs **without** WiFi however, the port can be enabled on images dated *Sept. 14. 2020* or later, by using the serial console exposed through the microUSB port with a serial terminal emulator of choice, such as [tio](https://tio.github.io/) or [putty](https://www.putty.org/):

1. breaking into U-Boot (press any key before the 3 seconds timeout prompt)


       U-Boot SPL 2018.11-g768f3f3 (Aug 04 2020 - 10:24:09 +0000)
       PMIC:  PFUZE100 ID=0x10
       Normal Boot
       Trying to boot from MMC2
       
       
       U-Boot 2018.11-g768f3f3 (Aug 04 2020 - 10:24:09 +0000)
       
       CPU:   Freescale i.MX8MQ rev2.0 at 1000 MHz
       Reset cause: POR
       Model: SolidRun i.MX8MQ HummingBoard Pulse
       DRAM:  1 GiB
       MMC:   FSL_SDHC: 0, FSL_SDHC: 1
       Loading Environment from MMC... *** Warning - bad CRC, using default environment
       
       In:    serial
       Out:   serial
       Err:   serial
       Net:   
       Warning: ethernet@30be0000 (eth0) using random MAC address - d2:63:b4:50:9c:21
       eth0: ethernet@30be0000
       Hit any key to stop autoboot:  0
       => 

2. choosing the devicetree file for SoMs without WiFi

       => setenv fdtfile imx8mq-hummingboard-pulse-nowifi.dtb
       => saveenv
       Saving Environment to MMC... Writing to MMC(1)... OK

3. booting ahead

       => boot

Note: These changes are permanent only to this particular installation of U-Boot - and might revert on rtc reset or change to other images. We are working on a way to autodetect the SoM - but at this point manual selection is still required :(

## Customize

### Using custom Device-Tree Blobs

We are trying to follow Debian design patterns where possible especially in the boot process. The *flash-kernel* application is used for installing DTBs to /boot as well as creating a boot-script for u-boot to load kernel, ramdisk and dtb.

Using a custom DTB here is as simple as putting it in **/etc/flash-kernel/dtbs** and rerunning `flash-kernel`. From this point onwards whenever an update to the kernel, or parts of the ramdisk occurs *flash-kernel* will automatically pick up the provided DTB in /etc.

### Fork board-support packages

In order to properly support the i.MX8 including all of its multimedia capabilities, many custom debs that are not part of Debian have been created. These include an optimized kernel, the Vivante GPU userspace, gstreamer plugins and many more. There are 2 ways for getting the package sources:

1. use apt-get source, e.g.: `apt-get source linux-image-4.19.y-imx8-sr`

2. browse the [SolidRun github](https://github.com/SolidRun), and the old [packaging organization](https://github.com/mxOBS)

All of our packages can be built by invoking dpkg-buildpackage directly, or through git-buildpackage. If there are specific questions regarding packaging of customizations please contact us.

Also note that [our instance](https://obs.solid-build.xyz/) of the [OpenBuildService](https://openbuildservice.org/) which we use to automate builds is available to the public on request.

## Pure Debian (upstream)

Our long-term goal is enabling as much of our hardware upstream as part of Debian where feasible. Success is highly dependent on the efforts of the general community around the i.MX8M SoCs, as well as the amount of proprietary blobs involved. At this point no support for the SolidRun i.MX8M boards is present in Debian.
