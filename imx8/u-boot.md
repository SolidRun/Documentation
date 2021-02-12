## Introduction

Below are details how to build ATF (ARM Trusted Firmware), U-Boot (boot loader) and Linux kernel for i.MX8M HummingBoard Pulse and CuBox-Pulse

## Building U-Boot from Sources

### Toolchain

You can either build or download a ready-to-use toolchain. An example of such toolchains are from Linaro website.

When writing this document the following toolchain was used – http://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-i686_aarch64-linux-gnu.tar.xz

Linaro updates it’s toolchain quite often and more frequent one can be downloaded from here – http://releases.linaro.org/components/toolchain/binaries/

Download and extract the toolchain into some place; and as instructed below the CROSS_COMPILE environment variables needs to be set to the path of the toolchain prefex.

For instance if the toolchain was extracted under /opt/imx8m/toolchain/gcc-linaro-7.3.1-2018.05-i686_aarch64-linux-gnu/ then the CROSS_COMPILE needs to be set as follows –

    export ARCH=arm64
    export CROSS_COMPILE=/opt/imx8m/toolchain/gcc-linaro-7.3.1-2018.05-i686_aarch64-linux-gnu/bin/aarch64-linux-gnu-

### Download Source and Firmware

    git clone https://source.codeaurora.org/external/imx/imx-atf.git -b imx_4.19.35_1.0.0 arm-trusted-firmware
    git clone https://github.com/SolidRun/u-boot.git -b v2018.11-solidrun
    wget https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/firmware-imx-7.9.bin

### ATF

Building ATF is as follows – *make sure you have set your ARCH and CROSS_COMPILE environment variables as noted above*

    cd arm-trusted-firmware
    make PLAT=imx8mq bl31
    cp build/imx8mq/release/bl31.bin ../u-boot/
    cd ..

### Extract and copy firmware

Extract the NXP firmware archive and accept the end user agreement

    chmod +x firmware-imx-7.9.bin
    ./firmware-imx-7.9.bin
    cp firmware-imx-7.9/firmware/hdmi/cadence/signed_hdmi_imx8m.bin u-boot/
    cp firmware-imx-7.9/firmware/ddr/synopsys/lpddr4*.bin u-boot/

### U-Boot

Build U-Boot and generate the image - *make sure you have set your ARCH and CROSS_COMPILE environment variables as noted above*

## Deploying U-Boot

    make imx8mq_hb_defconfig
    make flash.bin

### to microSD

- from (any) Linux Device

       sudo dd if=flash.bin of=/dev/sd[x] bs=1024 seek=33

### to eMMC

- from Linux:

       # Data Partition
       sudo dd if=flash.bin of=/dev/mmcblk0 bs=1024 seek=33

       # Boot0
       echo 0 | sudo tee /sys/block/mmcblk0boot0/force_ro
       sudo dd if=flash.bin of=/dev/mmcblk0boot0 bs=1024 seek=33

       # Boot1
       echo 0 | sudo tee /sys/block/mmcblk0boot1/force_ro
       sudo dd if=flash.bin of=/dev/mmcblk0boot1

- from U-Boot Shell:

   This procedure assumes familiarity with the U-Boot Commandline, especially knowledge of filesystem or network access for loading files to memory. For casual users, installing u-boot from within Linux is recommended!

       # load u-boot binary to memory
       load mmc 1:1 ${kernel_addr_r} flash.bin
       # calculate u-boot binary size as number of 512-byte blocks (e.g. 1001332 bytes --> #blocks=ceil(1001332/512)=0x7ae)

       # select eMMC, data partition
       mmc dev 0
       # boot0: mmc dev 0 1
       # boot1: mmc dev 0 2

       # write u-boot binary to eMMC at 33k bytes (66x512 blocks) offset
       mmc write ${kernel_addr_r} 0x42 0x7ae

### to SPI Flash

- from U-Boot Shell:

       # load u-boot binary to memory
       load mmc 1:1 ${kernel_addr_r} flash.bin

       # erase flash (optional)
       # sf erase 0 0x1000000

       # write u-boot binary to flash
       sf write ${kernel_addr_r} 0 $filesize

## Configure Boot Sequence (DIPs S1+SW3)

On HummingBoard Pulse the Boot Sequence can be configured through the DIP switches S1 and SW3. In this section, **1** refers to the "*ON*" position as printed on the switch. Order is from left to right, e.g. 10 means switch 1 set to 1, and switch 2 set to 0.

### Boot Mode

The i.MX8M SoCs support the following 3 boot modes configurable through the S1 DIP switches on HummingBoard Pulse

- **00**: Use eFuse settings, fall-back to Serial Download on error.
- **01**: Serial Download
- **10**: Use eFuse settings, but override with GPIOs (DIP SW3); Can be disabled by blowing BT_FUSE_SEL.

### Boot Source (i.MX8MQ Hummingboard Pulse)

When boot mode is **10**, the DIP switches SW3 can be used for selecting the actual boot device:

- **1100**: microSD (mmc2)
- **0010**: eMMC (mmc1)
- **0001**: SPI Flash

### Boot Source (i.MX8MM Hummingboard Ripple)

When boot mode is **10**, the DIP switches SW3 can be used for selecting the actual boot device:

- **1100**: microSD (mmc2)
- **0011**: eMMC (mmc3)

#### Configure eMMC Boot Partition

| **Note:** i.MX8M Mini has the u-boot indices for sdhc and emmc swapped: `mmc 1` is eMMC there! |
| --- |


From the U-Boot Shell, the eMMC boot partition is configurabkle with the **mmc partconf** command. It takes either 1, or 4 paramaters:

    # print configuration of mmc 0
    mmc partconf 0
    BOOT_ACK: 0x0
    BOOT_PARTITION_ACCESS: 0x0
    PARTITION_ACCESS: 0x0

The most relevant piece here is the **BOOT_PARTITION_ACCESS** field. It takes one of the following values:

- **0**: do not boot from eMMC
- **1**: boot from boot0
- **2**: boot from boot1
- **7**: boot from data partition

PARTITION_ACCESS is supposed to control access to the boot partitions where 0 means no access, 1 means read-write for boot0 and 2 read-write for boot1. However this currently does not appear to have any effect. It is suggested to set this to 1 when booting from boot0, 2 when booting from boot1 and 0 when booting from the data partition.

So finally this is how a new configuration is applied:

    # configure mmc 0 to boot from, and enable access to, boot0
    mmc partconf 0 1 1 1
    # configure mmc 0 to boot from, and enable access to, boot1
    mmc partconf 0 1 2 2
    # configure mmc 0 to boot from the data partition, and disable access to boot partitions
    mmc partconf 0 1 7 0

## Linux Kernel

Kernel sources are found on SolidRun’s github site – https://github.com/SolidRun/linux-fslc.git

To build from source; follow the following steps –

    git clone https://github.com/SolidRun/linux-fslc.git -b solidrun-imx_4.9.x_imx8m_ga
    cd linux-fslc
    export CROSS_COMPILE=<point to you ARM64 cross compiler as indicated above>
    export ARCH=arm64
    make Image dtbs

The result files are –

    Image - kernel image in FIT format
    arch/arm64/boot/dts/freescale/fsl-imx8mq-hummingboard-pulse.dtb - HummingBoard pulse device tree

## Linux Kernel Support Matrix

Following is the support matrix for the HummingBoard Pulse and CuBox-Pulse –

| Feature | HummingBoard Pulse + i.MX8M SOM | CuBox Pulse + i.MX8M SOM |
| --- | --- | --- |
| i.MX8M quad | v | v |
| Micron 3GByte LPDDR4 (via ATF)| v | v
| SOM PCIe based 11ac / bt|v|N/A |
| SOM BT 5.0 | v | N/A |
| i.MX8M Gigabit Ethernet (with PoE 11af PD) | v | v |
| i.MX8M GPU (Vivante GC7000 Lite Driver) | v | v |
| i.MX8M Video Engine | v | v |
| HummingBoard Pulse Intel i210 NIC | v | N/A |
| eMMC | v | v |
| USB type C (USB 3.0) | v | N/A |
| 2x USB 3.0 | v (via onboard USB 3.0 hub) | v (native from i.MX8M) |
| mini PCIe (SIM card) | v | N/A |
| M.2 | v | N/A |
| HDMI 2.0 with CEC | v | v |
| Onboard analogue audio codec | x | N/A |
| FPC connector (digital audio etc…) | v | N/A |
| Reset button | v | v |
| 1x Configurable push button | x | N/A |
| MikroBus click interface | x | N/A |
| 3x LED indicators | x | N/A |
| RTC via AM1805AQ | x | N/A |
| RTC via RX6110SA | N/A | x |
| GPIO based IR receiver | x | x |
| MIPI-DSI | x | N/A |
| On SOM MIPI-CSI | x | x |
| On carrier MIPI-CSI | x | N/A |
| PWM front LED | N/A | x |
