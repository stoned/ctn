#!/bin/sh -
set -e

: ${HTTP_ECHO_TAG:=0.2.3}
: ${CENTOS_TAG:=centos7.7.1908}
: ${TINI_VERSION:=0.18.0}

target_name="${1:-stoned/ebug}"

target=$(buildah from docker://docker.io/centos:$CENTOS_TAG)

buildah run $target -- sh -c 'yum install -y epel-release && \
  yum install -y \
     bc \
     bind-utils \
     curl \
     fio \
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
  && yum clean all'

buildah run $target -- sh -c 'echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel && \
  useradd -G wheel user'

http_echo=$(buildah from docker.io/hashicorp/http-echo:$HTTP_ECHO_TAG)
http_echo_mnt=$(buildah mount $http_echo)

buildah copy $target $http_echo_mnt/http-echo /bin

buildah add $target https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-amd64 /sbin/tini

buildah run $target -- sh -c 'chmod 755 /sbin/tini'

buildah config --user user $target
buildah config --entrypoint '["/sbin/tini", "--"]' $target
buildah config --cmd '/bin/bash' $target

buildah umount $http_echo
buildah umount $target

buildah commit $target $target_name

buildah rm $target $http_echo
