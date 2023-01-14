# Yocto Guide

This page collects documentation and resources for common problems relating to development with Yocto.

## Download the pure Yocto without Vendor BSP

Most users of yocto start with a full BSP and setup scripts provided with an embedded systems.
In special situations however, e.g. when starting a new BSP, it can be desirable to start fresh.

There are possible paths from here:
1. OpenEmbedded: individual components only
2. Poky: a reference distribution including additional setup scripts and convenience
These instructions focus on path number 2.
After downloading poky below, both `README.OE-CORE` and `README.poky.md` are recommend reads.

To start - create an empty folder where all of the layers, configuration files and build artifacts will be created.
Then download the poky distribution:

```
mkdir PROJECT; cd PROJECT
git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b kirkstone origin/kirkstone
```

Additional layers may be downloaded to the same `PROJECT` directory, next to `poky`.

Generate a build directory.
It can live inside the poky directory - but placing it outside with a custom name is recommended to enable e.g. building different configurations from the same sources.

```
cd PROJECT/poky
. ./oe-init-build-env ../build-imx6-cubox
```

`oe-init-build-env` creates example configuration files for the build and shows some useful information - then changes directory to the build directory and configures environment variables for compiling yocto. Note that the same command may be repeated to recreate the environment variables without losing previous changes to the build directory.

Of the generated config files Two are most relevant:

- `conf/bblayers.conf`:
   Here all of the layers to be available for a build should be listed. The default is only enough for some generic x86 and emulator targets - most people want to add at least a bsp layer.
- `conf/local.conf`:
   This is where most build-time configuration should be made. There are simple options for default target device (machine), directory names or packaging format - but also complex options for distribution, repositories or SDKs.

Customising the `DL_DIR` outside of the build directory, e.g. to `PROJECT/downloads` is **highly recommended** to safe space and shorten the build-time especially when working on multiple projects.

## Creating a Custom Meta Layer

When developing for Yocto often existing recipes need to be tweaked, patches applied or new software added.
Yocto organises the recipes (build instructions) in "layers".
Unless the purpose of development is improving publicly available layers, custom solutions and contained projects should be organised independently.

The Yocto project provides excellent documentation on how to do this: [Yocto Project Documentation: Understanding and Creating Layers](https://docs.yoctoproject.org/dev/dev-manual/layers.html)

## Defining a new Machine

The concept of a target platform or device in Yocto is called "machine".
Defaults are provided for emulators of various architectures, as well as for the various popular instruction sets and variants.
See e.g. `find -type f poky/meta/conf/machine`.
Some background about the concept and usage is available in the [Yocto Project Documentation: Adding a New Machine](https://docs.yoctoproject.org/dev/dev-manual/new-machine.html).

All machine definitions live inside the `conf/machine/` directory suffixed by `.conf`.
A minimal machine definition should reference some predefined instruction set or cpu, e.g. "cortex-a9":

```
# Minimal machine with Cortex-A9 CPU
require conf/machine/include/imx-base.inc
require conf/machine/include/arm/armv7a/tune-cortexa9.inc
```

Attempting a build will then reveal common types of problems:

### recipe was skipped: incompatible with machine

```
linux-yocto PROVIDES virtual/kernel but was skipped: incompatible with machine imx6qdlcubox (not in COMPATIBLE_MACHINE)
ERROR: Required build target 'core-image-minimal' has no buildable providers.
Missing or unbuildable dependency chain was: ['core-image-minimal', 'virtual/kernel']
```

Yocto recipes related to specific hardware such as bootloader, kernel, firmware, drivers, ... often explicitly define the names of machines they are compatible with.
Examples:

```
# linux-yocto:
COMPATIBLE_MACHINE = "^(qemuarm|qemuarmv5|qemuarm64|qemux86|qemuppc|qemuppc64|qemumips|qemumips64|qemux86-64|qemuriscv64|qemuriscv32)$"

# linux-fslc:
COMPATIBLE_MACHINE = "(imx-generic-bsp)"
```

Obviously the newly created machine can not share the name of another.
Instead compatibility with specific other machines can be claimed by setting the `MACHINEOVERRIDES` variable in the machine definition.
For example to indicate compatibility with the `linux-fslc` recipe, set `MACHINEOVERRIDES =. "use-imx-generic-bsp:"`.

Note that sometimes there are additional required compatible machines harder to deduct form recipes. `linux-fslc` for example also requires specifying a specific product line, e.g. `MACHINEOVERRIDES =. "mx6q:use-imx-generic-bsp:"`.

### recipe was skipped: Either ... or ... must be set in the machine configuration

```
u-boot-fslc PROVIDES virtual/bootloader but was skipped: Either UBOOT_MACHINE or UBOOT_CONFIG must be set in the imx6qdlcubox machine configuration.
u-boot PROVIDES virtual/bootloader but was skipped: Either UBOOT_MACHINE or UBOOT_CONFIG must be set in the imx6qdlcubox machine configuration.
ERROR: Required build target 'core-image-minimal' has no buildable providers.
Missing or unbuildable dependency chain was: ['core-image-minimal', 'virtual/bootloader']
```

Here yocto provides clear instructions what should be done. Define appropriate values for the mentioned variables in the machine definition.
Alternatively a new recipe providing `virtual/bootloader` could be created.

The solution for i.MX6 Cubox-i is to choose the appropriate uboot configuration file that is part of the upstream sources: `UBOOT_MACHINE = "mx6cuboxi_defconfig"`
