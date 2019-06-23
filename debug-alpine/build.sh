#!/bin/sh -
set -e

: ${HTTP_ECHO_TAG:=0.2.3}
: ${ALPINE_TAG:=3.10}

target_name="${1:-stoned/ebug}"

target=$(buildah from docker://docker.io/alpine:$ALPINE_TAG)

buildah run $target -- sh -c 'apk add --no-cache \
  bash \
  bind-tools \
  busybox-extras \
  curl \
  lftp \
  iperf3 \
  iputils \
  jq \
  lsof \
  nmap \
  nmap-ncat \
  openssh-client \
  screen \
  socat \
  strace \
  sudo \
  tcpdump \
  tmux \
  wget \
  '
buildah run $target -- sh -c 'echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel && \
  adduser -D -G users user && \
  addgroup user wheel'

http_echo=$(buildah from docker.io/hashicorp/http-echo:$HTTP_ECHO_TAG)
http_echo_mnt=$(buildah mount $http_echo)

buildah copy $target $http_echo_mnt/http-echo /bin

buildah config --user user $target
buildah config --entrypoint /bin/bash $target
buildah config --cmd '' $target

buildah umount $http_echo
buildah umount $target

buildah commit $target $target_name

buildah rm $target $http_echo
