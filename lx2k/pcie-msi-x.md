# LX2160 PCI-E MSI-X Interrupts for Virtual Function Devices

LX2160A SoC supports MSI-X interrupts for up to 32 Physical Function (PF) and Virtual Function (VF) devices.
Linux relies on U-Boot to configure the controller and iommu Look-Up tables.

U-Boot by default only allocates entries for those devices discovered after initial link-up.
VFs in particular usually require runtime configuration and can therefore not be detected by U-Boot.

Instead it is possible to pre-allocate entries for virtual functions through U-Boot environment variables.
For details see [NXP U-Boot README.pci_iommu_extra](https://github.com/nxp-qoriq/u-boot/blob/lf_v2022.04/arch/arm/cpu/armv8/fsl-layerscape/doc/README.pci_iommu_extra).

Support for this feature was enabled in SolidRun BSP on 06/03/2026, ensure using bootloader image dated same day or later.

## Example: Intel 82599ES 10-Gigabit SFI/SFP+ Ethernet Controller

See below for an example configuration of Intel 82599ES dual-port SFP+ card, allocating MSI-X Interrupts:

- 1x for PCI-E Controller Root Bridge
- 2x for Intel card PFs
- 15x for Port #1 VFs
- 14x for Port #2 VFs

### U-Boot Configuration

Configure `pci_iommu_extra` environment variable allocating entries for the VFs on devices `06.00.00` and `06.00.01`. The entries should match U-Boot device numbering as shown by `pci` command.

```text
Hit any key to stop autoboot:  0
=> pci
BusDevFun  VendorId   DeviceId   Device Class       Sub-Class
_____________________________________________________________
02.00.00   0x1957     0x8d80     Bridge device           0x04
03.00.00   0x126f     0x2262     Mass storage controller 0x08
05.00.00   0x1957     0x8d80     Bridge device           0x04
06.00.00   0x8086     0x10fb     Network controller      0x00
06.00.01   0x8086     0x10fb     Network controller      0x00

=> setenv pci_iommu_extra pci@0x3800000,6.0.0,vfs=15,6.0.1,vfs=14
=> saveenv
Saving Environment to MMC... Writing to MMC(1)... OK
=> reset
```

During boot, just before "Starting kernel ...", there are two messages indicating success:

```text
Added 15 iommu VF mappings for PF 6.0.0
Added 14 iommu VF mappings for PF 6.0.1
```

If too many VFs are requested there will be an additional error, e.g.:

```text
ERROR: out of LUT indexes for BDF 1.19.3
```

### Linux U-Boot Configuration Check

Whether or not U-Boot allocated interrupt slots for all VFs can be confirmed by inspecting the device-tree in procfs.

E.g. on LX2160A Clearfog-CX two PCI-E Controllers are enabled - for M.2 and Full-size connectors:

- M.2 Connector:

  ```text
  root@localhost:~# hexdump -C /sys/firmware/devicetree/base/soc/pcie@3600000/msi-map
  root@localhost:~# hexdump -C /sys/firmware/devicetree/base/soc/pcie@3600000/iommu-map
  ```

- Full-Size (x8) Connector:

  ```text
  root@localhost:~# hexdump -C /sys/firmware/devicetree/base/soc/pcie@3800000/msi-map
  root@localhost:~# hexdump -C /sys/firmware/devicetree/base/soc/pcie@3800000/iommu-map
  ```

In case of success the line-count for each file should equal the number of PFs plus the number of VFs plus one, e.g.:

```text
root@localhost:~# hexdump -C /sys/firmware/devicetree/base/soc/pcie@3800000/msi-map
00000000  00 00 00 00 00 00 00 22  00 00 28 00 00 00 00 01  |......."..(.....|
00000010  00 00 01 00 00 00 00 22  00 00 28 01 00 00 00 01  |......."..(.....|
00000020  00 00 01 01 00 00 00 22  00 00 28 02 00 00 00 01  |......."..(.....|
00000030  00 00 01 80 00 00 00 22  00 00 28 03 00 00 00 01  |......."..(.....|
00000040  00 00 01 82 00 00 00 22  00 00 28 04 00 00 00 01  |......."..(.....|
00000050  00 00 01 84 00 00 00 22  00 00 28 05 00 00 00 01  |......."..(.....|
00000060  00 00 01 86 00 00 00 22  00 00 28 06 00 00 00 01  |......."..(.....|
00000070  00 00 01 88 00 00 00 22  00 00 28 07 00 00 00 01  |......."..(.....|
00000080  00 00 01 8a 00 00 00 22  00 00 28 08 00 00 00 01  |......."..(.....|
00000090  00 00 01 8c 00 00 00 22  00 00 28 09 00 00 00 01  |......."..(.....|
000000a0  00 00 01 8e 00 00 00 22  00 00 28 0a 00 00 00 01  |......."..(.....|
000000b0  00 00 01 90 00 00 00 22  00 00 28 0b 00 00 00 01  |......."..(.....|
000000c0  00 00 01 92 00 00 00 22  00 00 28 0c 00 00 00 01  |......."..(.....|
000000d0  00 00 01 94 00 00 00 22  00 00 28 0d 00 00 00 01  |......."..(.....|
000000e0  00 00 01 96 00 00 00 22  00 00 28 0e 00 00 00 01  |......."..(.....|
000000f0  00 00 01 98 00 00 00 22  00 00 28 0f 00 00 00 01  |......."..(.....|
00000100  00 00 01 9a 00 00 00 22  00 00 28 10 00 00 00 01  |......."..(.....|
00000110  00 00 01 9c 00 00 00 22  00 00 28 11 00 00 00 01  |......."..(.....|
00000120  00 00 01 81 00 00 00 22  00 00 28 12 00 00 00 01  |......."..(.....|
00000130  00 00 01 83 00 00 00 22  00 00 28 13 00 00 00 01  |......."..(.....|
00000140  00 00 01 85 00 00 00 22  00 00 28 14 00 00 00 01  |......."..(.....|
00000150  00 00 01 87 00 00 00 22  00 00 28 15 00 00 00 01  |......."..(.....|
00000160  00 00 01 89 00 00 00 22  00 00 28 16 00 00 00 01  |......."..(.....|
00000170  00 00 01 8b 00 00 00 22  00 00 28 17 00 00 00 01  |......."..(.....|
00000180  00 00 01 8d 00 00 00 22  00 00 28 18 00 00 00 01  |......."..(.....|
00000190  00 00 01 8f 00 00 00 22  00 00 28 19 00 00 00 01  |......."..(.....|
000001a0  00 00 01 91 00 00 00 22  00 00 28 1a 00 00 00 01  |......."..(.....|
000001b0  00 00 01 93 00 00 00 22  00 00 28 1b 00 00 00 01  |......."..(.....|
000001c0  00 00 01 95 00 00 00 22  00 00 28 1c 00 00 00 01  |......."..(.....|
000001d0  00 00 01 97 00 00 00 22  00 00 28 1d 00 00 00 01  |......."..(.....|
000001e0  00 00 01 99 00 00 00 22  00 00 28 1e 00 00 00 01  |......."..(.....|
000001f0  00 00 01 9b 00 00 00 22  00 00 28 1f 00 00 00 01  |......."..(.....|
00000200
root@localhost:~# hexdump -C /sys/firmware/devicetree/base/soc/pcie@3800000/iommu-map
00000000  00 00 00 00 00 00 00 23  00 00 28 00 00 00 00 01  |.......#..(.....|
00000010  00 00 01 00 00 00 00 23  00 00 28 01 00 00 00 01  |.......#..(.....|
00000020  00 00 01 01 00 00 00 23  00 00 28 02 00 00 00 01  |.......#..(.....|
00000030  00 00 01 80 00 00 00 23  00 00 28 03 00 00 00 01  |.......#..(.....|
00000040  00 00 01 82 00 00 00 23  00 00 28 04 00 00 00 01  |.......#..(.....|
00000050  00 00 01 84 00 00 00 23  00 00 28 05 00 00 00 01  |.......#..(.....|
00000060  00 00 01 86 00 00 00 23  00 00 28 06 00 00 00 01  |.......#..(.....|
00000070  00 00 01 88 00 00 00 23  00 00 28 07 00 00 00 01  |.......#..(.....|
00000080  00 00 01 8a 00 00 00 23  00 00 28 08 00 00 00 01  |.......#..(.....|
00000090  00 00 01 8c 00 00 00 23  00 00 28 09 00 00 00 01  |.......#..(.....|
000000a0  00 00 01 8e 00 00 00 23  00 00 28 0a 00 00 00 01  |.......#..(.....|
000000b0  00 00 01 90 00 00 00 23  00 00 28 0b 00 00 00 01  |.......#..(.....|
000000c0  00 00 01 92 00 00 00 23  00 00 28 0c 00 00 00 01  |.......#..(.....|
000000d0  00 00 01 94 00 00 00 23  00 00 28 0d 00 00 00 01  |.......#..(.....|
000000e0  00 00 01 96 00 00 00 23  00 00 28 0e 00 00 00 01  |.......#..(.....|
000000f0  00 00 01 98 00 00 00 23  00 00 28 0f 00 00 00 01  |.......#..(.....|
00000100  00 00 01 9a 00 00 00 23  00 00 28 10 00 00 00 01  |.......#..(.....|
00000110  00 00 01 9c 00 00 00 23  00 00 28 11 00 00 00 01  |.......#..(.....|
00000120  00 00 01 81 00 00 00 23  00 00 28 12 00 00 00 01  |.......#..(.....|
00000130  00 00 01 83 00 00 00 23  00 00 28 13 00 00 00 01  |.......#..(.....|
00000140  00 00 01 85 00 00 00 23  00 00 28 14 00 00 00 01  |.......#..(.....|
00000150  00 00 01 87 00 00 00 23  00 00 28 15 00 00 00 01  |.......#..(.....|
00000160  00 00 01 89 00 00 00 23  00 00 28 16 00 00 00 01  |.......#..(.....|
00000170  00 00 01 8b 00 00 00 23  00 00 28 17 00 00 00 01  |.......#..(.....|
00000180  00 00 01 8d 00 00 00 23  00 00 28 18 00 00 00 01  |.......#..(.....|
00000190  00 00 01 8f 00 00 00 23  00 00 28 19 00 00 00 01  |.......#..(.....|
000001a0  00 00 01 91 00 00 00 23  00 00 28 1a 00 00 00 01  |.......#..(.....|
000001b0  00 00 01 93 00 00 00 23  00 00 28 1b 00 00 00 01  |.......#..(.....|
000001c0  00 00 01 95 00 00 00 23  00 00 28 1c 00 00 00 01  |.......#..(.....|
000001d0  00 00 01 97 00 00 00 23  00 00 28 1d 00 00 00 01  |.......#..(.....|
000001e0  00 00 01 99 00 00 00 23  00 00 28 1e 00 00 00 01  |.......#..(.....|
000001f0  00 00 01 9b 00 00 00 23  00 00 28 1f 00 00 00 01  |.......#..(.....|
00000200
```

### Linux Configuration

Actual NIC VFs can be created from `sysfs` if the driver probed correctly, and the linux netdev names are known:

```text
root@localhost:~# dmesg | grep -i ixgbe
[    8.672268] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver
[    8.672275] ixgbe: Copyright (c) 1999-2016 Intel Corporation.
[    8.672576] ixgbe 0001:01:00.0: Adding to iommu group 12
[    9.854944] ixgbe 0001:01:00.0: Multiqueue Enabled: Rx Queue count = 16, Tx Queue count = 16 XDP Queue count = 0
[    9.855258] ixgbe 0001:01:00.0: 32.000 Gb/s available PCIe bandwidth (5.0 GT/s PCIe x8 link)
[    9.855337] ixgbe 0001:01:00.0: MAC: 2, PHY: 1, PBA No: E68793-007
[    9.855341] ixgbe 0001:01:00.0: 90:e2:ba:d8:34:68
[    9.857766] ixgbe 0001:01:00.0: Intel(R) 10 Gigabit Network Connection
[    9.858215] ixgbe 0001:01:00.1: Adding to iommu group 16
[   11.034982] ixgbe 0001:01:00.1: Multiqueue Enabled: Rx Queue count = 16, Tx Queue count = 16 XDP Queue count = 0
[   11.035293] ixgbe 0001:01:00.1: 32.000 Gb/s available PCIe bandwidth (5.0 GT/s PCIe x8 link)
[   11.035372] ixgbe 0001:01:00.1: MAC: 2, PHY: 1, PBA No: E68793-007
[   11.035375] ixgbe 0001:01:00.1: 90:e2:ba:d8:34:69
[   11.037642] ixgbe 0001:01:00.1: Intel(R) 10 Gigabit Network Connection
[   11.047403] ixgbe 0001:01:00.1 enP1p1s0f1: renamed from eth2
[   11.088007] ixgbe 0001:01:00.0 enP1p1s0f0: renamed from eth1
```

Spawn two VFs on the NICs first port (`enP1p1s0f0`):

```text
root@localhost:~# dmesg -n8
root@localhost:~# echo 2 > /sys/class/net/enP1p1s0f0/device/sriov_numvfs
[  112.867846] ixgbe 0001:01:00.0 enP1p1s0f0: SR-IOV enabled with 2 VFs
[  112.937433] ixgbe 0001:01:00.0: Multiqueue Enabled: Rx Queue count = 4, Tx Queue count = 4 XDP Queue count = 0
[  113.051738] pci 0001:01:10.0: [8086:10ed] type 00 class 0x020000
[  113.058496] pci 0001:01:10.2: [8086:10ed] type 00 class 0x020000
[  113.066502] ixgbevf: Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver
[  113.075175] ixgbevf: Copyright (c) 2009 - 2018 Intel Corporation.
[  113.081587] ixgbevf 0001:01:10.0: Adding to iommu group 17
[  113.087117] ixgbevf 0001:01:10.0: enabling device (0000 -> 0002)
[  113.094583] ixgbevf 0001:01:10.0: PF still in reset state.  Is the PF interface up?
[  113.102242] ixgbevf 0001:01:10.0: Assigning random MAC address
[  113.108639] ixgbevf 0001:01:10.0: 62:70:fe:97:36:ce
[  113.113523] ixgbevf 0001:01:10.0: MAC: 1
[  113.117443] ixgbevf 0001:01:10.0: Intel(R) 82599 Virtual Function
[  113.123646] ixgbevf 0001:01:10.2: Adding to iommu group 18
[  113.129173] ixgbevf 0001:01:10.2: enabling device (0000 -> 0002)
[  113.136612] ixgbevf 0001:01:10.2: PF still in reset state.  Is the PF interface up?
[  113.144267] ixgbevf 0001:01:10.2: Assigning random MAC address
[  113.150632] ixgbevf 0001:01:10.2: 2a:de:2c:34:ef:5c
[  113.155517] ixgbevf 0001:01:10.2: MAC: 1
[  113.159444] ixgbevf 0001:01:10.2: Intel(R) 82599 Virtual Function
[  113.171021] ixgbevf 0001:01:10.2 enP1p1s0f0v1: renamed from eth2
[  113.216996] ixgbevf 0001:01:10.0 enP1p1s0f0v0: renamed from eth1
```

If insufficient interrupt slots were allocated, the command above will generate kernel errors such as:

```text
[  575.158270] OF: /soc/pcie@3800000: no msi-map translation for id 0x180 on (null)
[  575.172357] OF: /soc/pcie@3800000: no msi-map translation for id 0x182 on (null)
[  575.196341] OF: /soc/pcie@3800000: no iommu-map translation for id 0x180 on (null)
[  575.225062] OF: /soc/pcie@3800000: no msi-map translation for id 0x180 on /interrupt-controller@6000000/gic-its@6020000
[  575.251340] OF: /soc/pcie@3800000: no iommu-map translation for id 0x182 on (null)
[  575.279924] OF: /soc/pcie@3800000: no msi-map translation for id 0x182 on /interrupt-controller@6000000/gic-its@6020000
```

Actual interrupts are allocated only when drivers bring up the card. In case of NICs this is delayed till `ifconfig up`.

```text
root@localhost:~# ip link set dev enP1p1s0f0 up
[  325.065796] ixgbe 0001:01:00.0: registered PHC device on enP1p1s0f0
[  325.181966] 8021q: adding VLAN 0 to HW filter on device enP1p1s0f0
root@localhost:~# ip link set dev enP1p1s0f0v0 up
[  328.516447] ixgbe 0001:01:00.0 enP1p1s0f0: VF Reset msg received from vf 0
[  328.538931] 8021q: adding VLAN 0 to HW filter on device enP1p1s0f0v0
```

Finally check `/proc/interrupts` to see if interrupts fired for the VFs:

```text
root@localhost:~# grep ITS-MSI /proc/interrupts
...
401:          0          0          0          0          0          0          0          0          0          0          0          0         43          0          0          0   ITS-MSI 134742016 Edge      enP1p1s0f0-TxRx-0
402:          0          0          0          0          0          0          0          0          0          0          0          0          0          0         43          0   ITS-MSI 134742017 Edge      enP1p1s0f0-TxRx-1
403:          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0         44   ITS-MSI 134742018 Edge      enP1p1s0f0-TxRx-2
404:         44          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0   ITS-MSI 134742019 Edge      enP1p1s0f0-TxRx-3
405:          0         22          0          0          0          0          0          0          0          0          0          0          0          0          0          0   ITS-MSI 134742020 Edge      enP1p1s0f0
406:          0          0         11          0          0          0          0          0          0          0          0          0          0          0          0          0   ITS-MSI 135004160 Edge      enP1p1s0f0v0-TxRx-0
407:          0          0          0         14          0          0          0          0          0          0          0          0          0          0          0          0   ITS-MSI 135004161 Edge      enP1p1s0f0v0
...
```

The last two lines (406: enP1p1s0f0v0-TxRx-0, 407: enP1p1s0f0v0) each show non-zero counters, indicating that MSI-X interrupts are functional.
