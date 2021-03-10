# openSUSE Leap 15.2 on Honeycomb Workstation

Disclaimer: openSUSE on Honeycomb is supported by choice from SUSE. We encourage anyone interested to engage with them for support.

## Requirements

[UEFI](https://github.com/SolidRun/lx2160a_uefi) installed to microSD or SPI

## Download

Download the latest openSUSE Release for aarch64 from: [opensuse.org](https://software.opensuse.org/distributions/leap#Ports-ports)
- [dvd](http://download.opensuse.org/ports/aarch64/distribution/leap/15.2/iso/openSUSE-Leap-15.2-DVD-aarch64-Media.iso)
- [netinstall](http://download.opensuse.org/ports/aarch64/distribution/leap/15.2/iso/openSUSE-Leap-15.2-NET-aarch64-Media.iso)

The installation media can be written to either optical media or USB drive, e.g. with (etcher.io).

## Choose Hardware Description Method

Both DeviceTree and ACPI are available to choose from, each with their own ~~bugs~~ features due to ongoing upstreaming and standardization efforts:

| Function | ACPI | DeviceTree |
| --- | --- | --- |
| USB | yes | yes |
| SATA | yes | yes |
| microSD | yes | yes |
| eMMC | yes | yes |
| 1gbps rj45 | yes* | no |
| 10gbps sfp+ (4x) | yes** | no |
| m.2 PCIe | yes | no |
| full PCIe x8 | yes | no |

Either can be selected through the UFI menu:

    Device Manager -> O/S Hardware Description Selection

**\***: onboard networking support currently requires [out-of-tree kernel patches](https://github.com/SolidRun/linux-stable/commits/linux-5.10.y-cex7).
**\*\***: 10gbps sfp+ interfaces are configured through NXPs [restool](https://source.codeaurora.org/external/qoriq/qoriq-components/restool)

**Hint: Choose ACPI, DeviceTree will crash on first boot right after installation finishes :(**

## Install

- connect serial console
- connect installation media
- power on
- optionally press escape to enter UEFI menu and force booting install media
- on GRUB menu: choose "Installation"

The menu-driven installer is mostly self-explanatory. Hint: The highlighted letter on menu items can be used with the alt key for faster navigation ...

Finally after the installation system reboots, remove installation media and optionally press escape to enter UEFI menu and force booting from the drive openSUSE has been installed to.

In case of success a prompt similar to below will appear:

    Welcome to openSUSE Leap 15.2 - Kernel 5.3.18-lp152.19-default (ttyAMA0).
    
    
    install login:

## Add forked Kernel package with Networking Support

    zypper ar -f http://download.opensuse.org/repositories/home:/mayerjosua:/honeycomb/openSUSE_Leap_15.2/ honeycomb
    zypper install --from=honeycomb kernel-default

## Configure Interfaces on SFP+

1. install restool

       git clone https://source.codeaurora.org/external/qoriq/qoriq-components/restool
       cd restool; make
       sudo install -v -m755 -o root -g root restool /usr/sbin/
       sudo install -v -m755 -o root -g root scripts/ls-main /usr/sbin/
       sudo ln -sv ls-main /usr/sbin/ls-addni
       sudo ln -sv ls-main /usr/sbin/ls-addmux
       sudo ln -sv ls-main /usr/sbin/ls-addsw
       sudo ln -sv ls-main /usr/sbin/ls-listni
       sudo ln -sv ls-main /usr/sbin/ls-listmac
       sudo ln -sv ls-main /usr/sbin/ls-debug
       sudo ln -sv ls-main /usr/sbin/ls-append-dpl

2. figure out endpoint name (looking at the back of the board)

   | **dpmac.9** | **dpmac.7** |
   | --- | --- |
   | **dpmac.10** | **dpmac.8** |

3. add interface

       sudo ls-addni dpmac.9

## Add service to enable the SFP interfaces in the boot time

1. Create a service file

        cat > /usr/lib/systemd/system/dpmac@.service << EOF
        [Unit]
        Description=SFP+ Ports manual activation
        
        [Service]
        Type=oneshot
        Restart=never
        ExecStart=/usr/bin/sleep %i ; /usr/sbin/ls-addni dpmac.%i
        
        [Install]
        WantedBy=network.target
        
        EOF

2. Enable the service

        sudo systemctl daemon-reload
        sudo systemctl enable dpmac@7 dpmac@8 dpmac@9 dpmac@10
        sudo systemctl start dpmac@7 dpmac@8 dpmac@9 dpmac@10

## Known Issues ##

- sometimes reboot doesn't actually reboot but rather hang at `[ 1255.019997] reboot: Restarting system`.
- kernel crashes on boot with devicetree.
- fails to mount rootfs on first boot, **if installed to NVMe**. As a work-around on grub menu press 'e' to edit the openSUSE entry and append 'irqpoll' to the line starting with 'linux'. system-updates should resolve this.
- 10gbps interafaces do not come up automatically.
