# Run DPDK on LX2160a

## Install

### Install Dependencies

    apt-get install build-essential git meson pciutils

### Download Sources

    git clone https://github.com/nxp-qoriq/dpdk
    cd dpdk
    git reset --hard LSDK-21.08
    wget https://github.com/SolidRun/Documentation/raw/bsp/lx2k/dpdk/0001-bus-fslmc-fix-invalid-use-of-default-vfio-config.patch
    git am 0001-bus-fslmc-fix-invalid-use-of-default-vfio-config.patch
    cd ..

### Compile

    meson dpdk dpdk-build
    ninja -C dpdk-build

## Start

### Bind native NICs

    bash ./dpdk/nxp/dpaa2/dynamic_dpl.sh dpmac.3 dpmac.4 dpmac.5 dpmac.6 dpmac.7 dpmac.8 dpmac.9 dpmac.10
    export DPRC=dprc.2

### Bind PCIe NICs

    echo Y > /sys/module/vfio_pci/parameters/disable_idle_d3
    ./dpdk/usertools/dpdk-devbind.py --bind vfio-pci 01:00.*

### Enable huge pages

    ./dpdk/usertools/dpdk-hugepages.py --setup 2G

### Run testpmd

    ./dpdk-build/app/dpdk-testpmd -- -i
    ./dpdk-build/app/dpdk-testpmd -a 01:00.0 -a 01:00.1 -a 01:00.2 -a 01:00.3 -- -i
