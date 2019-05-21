#!/bin/sh -
set -e

target_name="${1:-stoned/ebug}"

target=$(buildah from docker://docker.io/centos:latest)

buildah run $target -- sh -c 'yum install -y epel-release && \
    yum install -y \
     bc \
     bind-utils \
     curl \
     ftp \
     httping \
     iperf3 \
     iproute \
     jq \
     lsof \
     net-tools \
     nmap \
     openssh-clients \
     screen \
     socat \
     strace \
     sudo \
     tcpdump \
     telnet \
     tmux \
     traceroute \
     wget \
     && \
    yum clean all'
buildah run $target -- sh -c 'echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel && \
    useradd -G wheel user'

http_echo=$(buildah from docker.io/hashicorp/http-echo:latest)
http_echo_mnt=$(buildah mount $http_echo)

buildah copy $target $http_echo_mnt/http-echo /bin

buildah config --user user $target
buildah config --entrypoint /bin/bash $target
buildah config --cmd '' $target

buildah umount $http_echo
buildah umount $target

buildah commit $target $target_name

buildah rm $target $http_echo
