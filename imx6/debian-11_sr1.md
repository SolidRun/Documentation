# SolidRun Debian 11 for i.MX6 - Release 1

## Summary

- Upstream Release: Debian 11
- SolidRun Release: 1
- Hardware
  - Cubox-i
  - HummingBoard Base
  - HummingBoard Pro
  - HummingBoard Edge
  - HummingBoard Gate
- Features:
  - Ports:
    - microSD
    - eMMC todo
    - mSATA (HummingBoard only)
    - eSATA (Cubox-i only)
    - Ethernet
    - SoM integrated WiFi+Bluetooth
    - 2x USB-2.0 Type A
    - additional 2x USB-2.0 Type A (HummingBoard Edge/Gate only)
    - 3.5mm audio jack
    - HDMI
    - ~~MIPI-CSI-2~~ (partially tested)
  - Multimedia:
    ~~- OpenCL~~ (not currently supported)
    - OpenGL-ES 2.0 todo
    - GStreamer HW-Accelerated Video Decoder
      - MPEG2
      - ~~MPEG4~~ (not tested)
      - H.264
    - ALSA Audio Playback
      - ~~HDMI~~ broken
      - SPDIF (some Cubox-i only)
      - 3.5mm jack (HummingBoard only)
- Major Components:
  - Linux 5.10 from the Debian project

## Download

- [i.MX6, microSD bootable](https://images.solid-run.com/IMX6/Debian/sr-imx6-debian-bullseye-20210904-cli-sdhc.img.xz)

# Documentation

## Install

All images are designed for raw deployment byte by byte (**not as a file**) to block storage such as microSD cards. Several tools can be used, including `dd`, `win32diskimager` and [etcher.io](https://etcher.io/). Note that care must be taken to decompress the image file for the first 2, while *etcher.io* can also handle the compressed image.

## Log In

Once greeted by a login prompt, the default username and password are both "debian". For security reasons there is **no** root password! If you really need one, you can run `sudo passwd root` to set your own.
For remote sessions, ssh is preconfigured. Check your router for finding the devcies IP address, or try the default hostname *sr-imx6*.

## Usage Hints

### Wayland

While it is possible to install full destop environmnts such as Gnome, for testing functionality the reference compositor weston should be used:

      # install weston
      sudo apt install weston
      
      # start weston FROM A PHYSICAL TERMINAL not remote or serial session
      weston-launch -- --backend=drm-backend.so
      # by default one application is available, the terminal emulator, at the upper left corner.

### X11

X11 is only partially functional:
- the cursor is invisible with *twm*
- video playback crashes X server, because the XV extension uses an unsupported glsl version

Install:

      sudo apt install twm xinit xserver-xorg xserver-xorg-input-evdev xterm

Configure:

      cat << EOF | sudo tee /etc/X11/xorg.conf.d/etnaviv.conf
      Section "Device"
        Identifier "etnaviv"
        Driver "modesetting"
        Option "kmsdev" "/dev/dri/card1"
        Option "AccelMethod" "glamor"
        Option "HWcursor" "False"
      EndSection

      Section "ServerFlags"
        Option "AutoAddGPU" "false"
      EndSection
      EOF

      # configure application startup
      cat > .xinitrc << EOF
      twm &
      xterm
      EOF

Run:

      # start X server FROM A PHYSICAL TERMINAL not remote or serial session
      startx

### OpenGL-ES

- eglinfo

  A Mesa demo application for showing supported EGL APIs and extensions

      sudo apt-get install mesa-utils-extra

      eglinfo

- glmark2

  Benchmark for OpenGL-ES 2.0 - available [here on github](https://github.com/glmark2/glmark2).
  Instructions for building and running a compatible fork from source:

      sudo apt-get install build-essential git libdrm-dev libegl-dev libgbm-dev libgles-dev libjpeg-dev libpng-dev libudev-dev libwayland-dev pkg-config python
      git clone -b fbdev https://github.com/Josua-SR/glmark2.git
      cd glmark2
      ./waf configure --with-flavors=drm-glesv2,wayland-glesv2,x11-glesv2
      ./waf build -j4
      sudo ./waf install

      # from a wayland session
      glmark2-es2-wayland
      # from an X session
      glmark2-es2

### GStreamer Examples

Suggested packages for Audio and Video:

    sudo apt install gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-alsa gstreamer1.0-tools

- Text-Mode (KMS):

      export GST_GL_PLATFORM=egl GST_GL_API=gles2 GST_GL_WINDOW=gbm

      wget https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_1080p_h264.mov
      # H.264: video only
      gst-launch-1.0 filesrc location=$PWD/big_buck_bunny_1080p_h264.mov ! parsebin ! v4l2h264dec ! videoconvert ! kmssink

      wget http://docs.evostream.com/sample_content/assets/bun33s.ts
      # MPEG2: video only
      gst-launch-1.0 filesrc location=$PWD/bun33s.ts ! parsebin ! v4l2mpeg2dec ! videoconvert ! kmssink

- Wayland:

      export GST_GL_PLATFORM=egl GST_GL_API=gles2 GST_GL_WINDOW=wayland

      wget https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_1080p_h264.mov
      # H.264: video only
      gst-launch-1.0 filesrc location=$PWD/big_buck_bunny_1080p_h264.mov ! parsebin ! v4l2h264dec ! videoconvert ! waylandsink fullscreen=1
      # H.264, AAC: video + analog stereo audio (3.5mm jack)
      gst-launch-1.0 filesrc location=$PWD/big_buck_bunny_1080p_h264.mov ! parsebin name=p p. ! queue ! v4l2h264dec ! videoconvert ! waylandsink fullscreen=1 p. ! queue ! avdec_aac ! audioconvert ! alsasink device=dmix:CARD=Codec

      wget http://docs.evostream.com/sample_content/assets/bun33s.ts
      # MPEG2: video only
      gst-launch-1.0 filesrc location=$PWD/bun33s.ts ! parsebin ! v4l2mpeg2dec ! videoconvert ! waylandsink

- X11:

  Due to a combined problem with xf86-video-modesetting, the implementation of the XV extension in glamor and mesa, accelerated video playback does not currently work on X.

### MIPI-CSI2 Video Capture

This section provides an example for how a common TC358743 HDMI capture card would be used with the CSI-2 port on a HummingBoard Base or Pro.
The instructions below are incomplete, because during testing the author was not able to actually capture a frame. Likely this has been due to the particular capture card used, and problems in how it has been wired.

i.MX6 SoCs support complex configuration of video capture using a number of processing elements, including scaling, colour conversions and overlay from multiple sources. For details, refer to the official [documentation for the i.MX Video Capture Driver](https://www.kernel.org/doc/html/latest/admin-guide/media/imx.html)!
Below are example configuration steps for unprocessed capture the sensor:

```
# configure pipeline
media-ctl -l "'tc358743 0-000f':0->'imx6-mipi-csi2':0[1]"
media-ctl -l "'imx6-mipi-csi2':1->'ipu1_csi0_mux':0[1]"
media-ctl -l "'ipu1_csi0_mux':2->'ipu1_csi0':0[1]"
media-ctl -l "'ipu1_csi0':2->'ipu1_csi0 capture':0[1]"
```

The HDMI Capture Card requires loading EDID data, to allow negotiation of timings with the source. An example file supporting 720p is available from the pikvm project: [tc358743-edid.hex](https://github.com/pikvm/kvmd/raw/master/configs/kvmd/tc358743-edid.hex)
It can be loaded by th following steps:

```
# find sensor v4l sub-device device node
media-ctl -p -e 'tc358743 0-000f'
- entity 61: tc358743 0-000f (1 pad, 1 link)
             type V4L2 subdev subtype Unknown flags 0
             device node name /dev/v4l-subdev7

# load edid
v4l2-ctl -d /dev/v4l-subdev7 --set-edid=file=tc358743-edid.hex
```

The negotiated timings are not applied automatically. On first use, and any time a different source is connected, this has to be re-run!

```
# view and apply negotiated timings:
v4l2-ctl -d /dev/v4l-subdev7 --query-dv-timings
v4l2-ctl -d /dev/v4l-subdev7 --set-dv-bt-timings query
```

Picture format is not currently propagated through the capture pipeline. Below steps configure a default for 720p UYVY:

```
# view current configuration:
media-ctl -p -e 'tc358743 0-000f'
media-ctl -p -e 'imx6-mipi-csi2'
media-ctl -p -e 'ipu1_csi0_mux'
media-ctl -p -e 'ipu1_csi0'
# configure 1280x720@uyvy
media-ctl --set-v4l2 "'tc358743 0-000f':0[fmt:UYVY/1280x720]"
media-ctl --set-v4l2 "'imx6-mipi-csi2':1[fmt:UYVY2X8/1280x720]"
media-ctl --set-v4l2 "'ipu1_csi0_mux':2[fmt:UYVY/1280x720]"
media-ctl --set-v4l2 "'ipu1_csi0':2[fmt:AYUV32/1280x720]"
```

Now 720p video should be available on the mipi-csi2 receiver block. As a last step, the video format has to be configured for the v4l2 capture device:

```
# find v4l capture device device node
media-ctl -p -e 'ipu1_csi0 capture'
- entity 5: ipu1_csi0 capture (1 pad, 1 link)
            type Node subtype V4L flags 0
            device node name /dev/video4
        pad0: Sink
                <- "ipu1_csi0":2 [ENABLED]

# view current capture format:
v4l2-ctl -d /dev/video4 --get-fmt-video
# configure 720p UYVY
v4l2-ctl -d /dev/video4 --set-fmt-video width=1280,height=720,pixelformat=UYVY
media-ctl --set-v4l2 "'tc358743 0-000f':0[fmt:UYVY/1280x720]"
# confirm format:
v4l2-ctl -d /dev/video4 --get-fmt-video
Format Video Capture:
        Width/Height      : 1280/720
        Pixel Format      : 'UYVY' (UYVY 4:2:2)
        Field             : None
        Bytes per Line    : 2560
        Size Image        : 1843200
        Colorspace        : SMPTE 170M
        Transfer Function : Rec. 709
        YCbCr/HSV Encoding: ITU-R 601
        Quantization      : Limited Range
        Flags             :
```

Congratulations for reading this far! If the step below works for you, we would love to hear about it!

Finally, try to capture one frame:

```
v4l2-ctl -d /dev/video4 --stream-mmap --stream-to=frame.raw --stream-count=1
```

### ALSA Examples

    sudo apt install vorbis-tools
    wget https://github.com/KDE/amarok/raw/master/data/first_run_jingle.ogg
    # play to 3.5mm jack
    ogg123 -d alsa -o dev:dmix:CARD=Codec first_run_jingle.ogg
    # play to hdmi
    ogg123 -d alsa -o dev:dmix:CARD=DWHDMI first_run_jingle.ogg
    # play to spdif
    ogg123 -d alsa -o dev:dmix:CARD=SPDIF first_run_jingle.ogg

## Known Issues

### No IP on eth0 when connecting cable after boot

When booting the system without ethernet cable connected, the interface will not acquire an IP address by DHCP when hotplugging the cable later. As a workaround the interface can be cycled down and up:

    ifdown eth0
    ifup eth0
