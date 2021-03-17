## Introduction

Below are details how to build ATF (ARM Trusted Firmware), U-Boot (boot loader) and Linux kernel for i.MX8M Nano - Compact

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
    ROOTDIR=`pwd`
    git clone https://source.codeaurora.org/external/imx/imx-atf -b rel_imx_5.4.70_2.3.0
    git clone https://source.codeaurora.org/external/imx/uboot-imx -b imx_v2020.04_5.4.70_2.3.0
    FW_VERSION=firmware-imx-8.10
    wget https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/${FW_VERSION}.bin

 **Note:** Install and applay the U-Boot patches from here https://github.com/SolidRun/imx8mp_build/tree/imx8mn/patches |
| --- |

### ATF

Building ATF is as follows – *make sure you have set your ARCH and CROSS_COMPILE environment variables as noted above*

    cd ${ROOTDIR}/arm-trusted-firmware
    make PLAT=imx8mn bl31
    cp build/imx8mn/release/bl31.bin ${ROOTDIR}/uboot-imx/

### Extract and copy firmware

Extract the NXP firmware archive and accept the end user agreement
    
    cd ${ROOTDIR}
    chmod +x ${FW_VERSION}.bin
    ${ROOTDIR}/${FW_VERSION}.bin
    cp ${ROOTDIR}/${FW_VERSION}/firmware/hdmi/cadence/signed_hdmi_imx8m.bin ${ROOTDIR}/uboot-imx/
    cp ${ROOTDIR}/${FW_VERSION}/firmware/ddr/synopsys/ddr4*.bin ${ROOTDIR}/uboot-imx/

### U-Boot

Build U-Boot and generate the image - *make sure you have set your ARCH and CROSS_COMPILE environment variables as noted above*

## Deploying U-Boot
    
    cd ${ROOTDIR}/uboot-imx/
    make imx8mn_solidrun_defconfig
    make flash.bin

The result file is -

    ${ROOTDIR}/uboot-imx/flash.bin 

### to microSD

- from (any) Linux Device

       sudo dd if=flash.bin of=/dev/sd[x] bs=1024 seek=32

### to eMMC

- from Linux:

       # Data Partition
       sudo dd if=flash.bin of=/dev/mmcblk0 bs=1024 seek=32

       # Boot0
       echo 0 | sudo tee /sys/block/mmcblk0boot0/force_ro
       sudo dd if=flash.bin of=/dev/mmcblk0boot0 bs=1024 seek=32

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

       # write u-boot binary to eMMC at 32k bytes (64x512 blocks) offset [hex(64)=0x40]
       mmc write ${kernel_addr_r} 0x40 0x7ae

### to SPI Flash

- from U-Boot Shell:

       # load u-boot binary to memory
       load mmc 1:1 ${kernel_addr_r} flash.bin

       # erase flash (optional)
       # sf erase 0 0x1000000

       # write u-boot binary to flash
       sf write ${kernel_addr_r} 0 $filesize

## Configure Boot Sequence (DIPs S1)

On Compact the Boot Sequence can be configured through the DIP switches S1. In this section, **1** refers to the "*ON*" position as printed on the switch. Order is from left to right, e.g. 10 means switch 1 set to 1, and switch 2 set to 0.

### Boot Source (i.MX8MN Compact)

the DIP switches S1 can be used for selecting the actual boot device:

- **11**: microSD (mmc1)
- **01(not tested yet)**: eMMC (mmc2)

From the U-Boot Shell, the eMMC boot partition is configurabkle with the **mmc partconf** command. It takes either 1, or 4 paramaters:

    # print configuration of mmc 2
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

    # configure mmc 2 to boot from, and enable access to, boot0
    mmc partconf 2 1 1 1
    # configure mmc 2 to boot from, and enable access to, boot1
    mmc partconf 2 1 2 2
    # configure mmc 2 to boot from the data partition, and disable access to boot partitions
    mmc partconf 2 1 7 0

## Linux Kernel

### Download Source
    ROOTDIR=`pwd`    
    git clone https://source.codeaurora.org/external/imx/linux-imx -b rel_imx_5.4.70_2.3.0

 **Note:** Install and applay the Linux patches from here https://github.com/SolidRun/imx8mp_build/tree/imx8mn/patches/linux-imx |
| --- |

To build from source; follow the following steps –

    cd ${ROOTDIR}/linux-imx
    export CROSS_COMPILE=<point to you ARM64 cross compiler as indicated above>
    export ARCH=arm64
    make Image dtbs

The result files are –

    Image - kernel image in FIT format
    arch/arm64/boot/dts/freescale/imx8mn-compact.dtb - Compact device tree

