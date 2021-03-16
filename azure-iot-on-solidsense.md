This is a proof of concept installation of Azure IoT Edge Agent version 1.1.0 on Debian 10.

## Prepared Image

[Download Image for SolidSense](https://images.solidsense.io/SolidSense/SolidSense-OEM-debian-buster-aziot.img.xz)

1. deploy image to block device, e.g. microSD card:

   - Generic, GUI [etcher.io](https://www.balena.io/etcher/)
   - Linux CLI

          xzcat sr-imx6-debian-buster-aziot.img > /dev/sdY; sync

2. Optionally resize root filesystem according to backing block device. RedHat is one source providing [instructions for resizing partitions](https://access.redhat.com/articles/1190213) as well as [instructions for growing a filesystem](https://access.redhat.com/articles/1196353). The most important detail is to keep the partition's start sector and signature (type) as it was! Other more friendly tools such as gparted are also usable.

3. Power-on SolidSense, wait till it appears on the network, then ssh with username=debian and password=debian; default hostname will be sr-imx6-aziot.

4. Configure Edge Agent: */etc/iotedge/config.yaml*

   At a minimum, the devices connection string has to be copied from the Azure Portal to this file in the provisioning section:

       provisioning:
         source: "manual"
         device_connection_string: "<paste connection string here>"
         dynamic_reprovisioning: false

5. Restart Edge Agent to apply Configuration

       systemctl restart iotedge

## Manual (Generic) Installation

Starting with an existing installation of Debian 10 armhf port:

1. Install docker:

       apt-get install docker.io

       cat > /etc/docker/daemon.json << EOF
       {
           "dns": ["9.9.9.9"],
           "log-driver": "json-file",
           "log-opts": {
               "max-size": "10m",
               "max-file": "3"
           }
       }
       EOF

2. Install Edge Agent:

       wget https://github.com/Azure/azure-iotedge/releases/download/1.1.0/iotedge_1.1.0-1_debian9_armhf.deb
       wget https://github.com/Azure/azure-iotedge/releases/download/1.1.0/libiothsm-std_1.1.0-1-1_debian9_armhf.deb
       dpkg -i iotedge_1.1.0-1_debian9_armhf.deb libiothsm-std_1.1.0-1-1_debian9_armhf.deb

3. Configure Edge Agent: */etc/iotedge/config.yaml*

   At a minimum, the devices connection string has to be copied from the Azure Portal to this file in the provisioning section:

       provisioning:
         source: "manual"
         device_connection_string: "<paste connection string here>"
         dynamic_reprovisioning: false

4. Restart Edge Agent to apply Configuration

       systemctl restart iotedge

## Notes

- Currently even though Microsoft specifies that Debian 10 is supported, the current stable release (1.1.0) provides only packages targeting Debian 9.
- The release candidate 1.2.0-rc4 is broken on Debian 10 armhf, for both VMs and physical machines: https://github.com/Azure/iotedge/issues/4609
