## Introduction
This page describes how to build, install and update the TianoCore EDK2 firmware for SolidRun Armada 8040-based devices.
It is currently available for the MacchiatoBin only, while we are working on extending it to the Clearfog GT 8k as well.

## Prebuilt Binaries

Usable firmware binaries are available at https://images.solid-build.xyz/8040/UEFI/.

## Scripted Build using a Container

A docker container can be used to build the uefi firmware in a controlled environment by following the steps below:

- Create Container Image and Workspace

   The container source and build scripts are managed in [this github repository](https://github.com/Josua-SR/boot-builder/tree/armada-8040-uefi). The steps below clone the repository and build the container image:

       git clone https://github.com/Josua-SR/boot-builder.git -b armada-8040-uefi
       cd boot-builder

       docker build -t 8040efibldr docker

    The clone has been designed to act as the workspace - keeping source code and build results inside the cloned folder. The steps following are to be run from within the cloned folder, here *boot-builder*.

- Download Source Code

       docker run -v "$PWD:/work" 8040efibldr -u $(id -u) -g $(id -g) -- init
       docker run -itv "$PWD:/work" 8040efibldr -u $(id -u) -g $(id -g) -- sync

- Compile Firmware Image

       docker run -itv "$PWD:/work" 8040efibldr -u $(id -u) -g $(id -g) -- build

   The resulting firmware binary will be copied to the working directory as `uefi-mcbin-spi.bin`.

## Manual Build

### Install a cross-compiler

Either GCC or Clang are suitable for building EDK2. We suggest using the cross-compiler that ships with your distro of choice, or picking up a recent version of the Linaro Toolchain binary releases, e.g. [version 7](https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/).

**The environment variables *GCC5_AARCH64_PREFIX* and *CROSS_COMPILE* in the instructions below must be adapted based on this choice!**

### Download Source Code

All Source-Code is available on GitHub. It is recommended to clone below versions into a new directory for performing the build in. We use "build-edk2" here.

    mkdir build-edk2; cd build-edk2
    git clone --recurse-submodules https://github.com/tianocore/edk2.git -b edk2-stable201908
    git clone https://github.com/tianocore/edk2-non-osi.git -b master
    git clone https://github.com/tianocore/edk2-platforms.git -b master
    git clone https://github.com/MarvellEmbeddedProcessors/atf-marvell.git -b atf-v1.5-armada-18.12
    git clone https://github.com/MarvellEmbeddedProcessors/binaries-marvell.git -b binaries-marvell-armada-18.12
    git clone https://github.com/MarvellEmbeddedProcessors/mv-ddr-marvell.git -b mv_ddr-armada-18.12

### Compile EDK2

    cd build-edk2

    export export WORKSPACE=$PWD
    export PACKAGES_PATH=$PWD/edk2:$PWD/edk2-platforms:$PWD/edk2-non-osi
	export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-

    make -C edk2/BaseTools
    source edk2/edksetup.sh
    build -a AARCH64 -b RELEASE -t GCC5 -p Platform/SolidRun/Armada80x0McBin/Armada80x0McBin.dsc -D X64EMU_ENABLE

    ls Build/Armada80x0McBin-AARCH64/RELEASE_GCC5/FV/ARMADA_EFI.fd

### Compile Final Image with ATF
    cd build-edk2

    export CROSS_COMPILE=aarch64-linux-gnu-

    make -C atf-marvell \
    		PLAT=a80x0_mcbin \
    		MV_DDR_PATH=$PWD/mv-ddr-marvell \
    		SCP_BL2=$PWD/binaries-marvell/mrvl_scp_bl2.img \
    		BL33=$PWD/Build/Armada80x0McBin-AARCH64/RELEASE_GCC5/FV/ARMADA_EFI.fd \
    		all fip

    cp atf-marvell/build/a80x0_mcbin/release/flash-image.bin uefi-mcbin-spi.bin

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

For installing the new firmware binary from U-Boot, follow the [instructions for writing U-Boot to SPI Flash](https://developer.solid-run.com/knowledge-base/armada-8040-machiatobin-u-boot-and-atf/#to-spi-flash)
