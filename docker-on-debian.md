Tested with
- [SolidRun Debian Buster for i.MX8MQ (2020-07-13)](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-buster-20200713-cli-imx8mq-sdhc.img.xz)
- [SolidRun Debian Buster for i.MX8M Mini (2020-04-28)](https://images.solid-run.com/IMX8/Debian/sr-imx8-debian-buster-20200428-cli-imx8mm-sdhc.img.xz)

Note: While not explicitly test, these instructions also apply for i.MX6, A38X and 8040 images.

## Upgrade System

People keep underestimating this step, but it does install a newer kernel build with some docker required features enabled ...

    sudo apt update
    sudo apt upgrade

## Configure Package Source

    sudo apt install gnupg2
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    echo "deb [arch=arm64] https://download.docker.com/linux/debian buster stable" | sudo tee /etc/apt/sources.list.d/docker.list
    # substitute arm64 with armhf on i.MX6 and A38X ...

## Install Docker Engine

    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io

## grant current unprivileged user access to docker daemon

    sudo usermod -a -G docker $(id -u -n)
    logout # required for group membership to take effect

## Hello, World

    docker info
    docker run hello-world

## References

- [docker.com: Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/)
