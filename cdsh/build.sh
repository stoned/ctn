#!/bin/sh -

# [Universal Base Images (UBI): Images, repositories, and packages](https://access.redhat.com/articles/4238681)

set -e

: ${UBI7_MINIMAL_TAG:=7.7-98}
: ${OC_CLIENT_VERSION:=3.11.0-0cbc58b}
: ${KUSTOMIZE_VERSION:=3.2.1}
: ${YQ_VERSION:=2.4.0}
: ${JQ_VERSION:=1.6}
: ${CONFTEST_VERSION:=0.13.0}
: ${OPA_VERSION:=0.14.1}

tmpdir="$(mktemp -d -p ${TMPDIR:-/tmp}  $(basename $0).XXXXXXXXXX)"
trap "rm -rf \"$tmpdir\"" 0 1 2 3 15
cd ${tmpdir}

target_name="${1:-stoned/cdsh}"

target=$(buildah from docker://registry.access.redhat.com/ubi7/ubi-minimal:$UBI7_MINIMAL_TAG)

# misc tools and command
buildah run $target -- sh -c 'microdnf --nodocs install \
   gzip \
   java-11-openjdk \
   less \
   nmap-ncat \
   openssh-clients \
   openssl \
   python \
   rsync \
   shadow-utils \
   socat \
   sudo \
   unzip \
   vim-minimal \
  '

# openshift client
u=https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v${OC_CLIENT_VERSION}-linux-64bit.tar.gz
wget $u
tar zxf $(basename $u)
buildah add $target $(basename $u .tar.gz)/oc /usr/bin/oc
buildah run $target -- sh -c 'chmod 755 /usr/bin/oc'
buildah run $target -- sh -c 'ln -s oc /usr/bin/kubectl'

# kustomize
buildah add $target https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_kustomize.v${KUSTOMIZE_VERSION}_linux_amd64 /usr/bin/kustomize
buildah run $target -- sh -c 'chmod 755 /usr/bin/kustomize'

# yq
buildah add $target https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 /usr/bin/yq
buildah run $target -- sh -c 'chmod 755 /usr/bin/yq'

# jq
buildah add $target https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 /usr/bin/jq
buildah run $target -- sh -c 'chmod 755 /usr/bin/jq'

# conftest
u=https://github.com/instrumenta/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz
wget $u
tar zxf $(basename $u)
buildah add $target ./conftest /usr/bin/conftest
buildah run $target -- sh -c 'chmod 755 /usr/bin/conftest'

# opa
buildah add $target https://github.com/open-policy-agent/opa/releases/download/v${OPA_VERSION}/opa_linux_amd64 /usr/bin/opa
buildah run $target -- sh -c 'chmod 755 /usr/bin/opa'

# user
buildah run $target -- sh -c 'echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel && \
  useradd -G wheel user'

# runtime config
buildah config --user user $target
buildah config --cmd '/bin/bash' $target

buildah umount $target

buildah commit $target $target_name

buildah rm $target
