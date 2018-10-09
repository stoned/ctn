FROM centos:7.5.1804
RUN yum install -y epel-release && \
    yum install -y \
     bc \
     bind-utils \
     curl \
     ftp \
     httping \
     iperf3 \
     jq \
     lsof \
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
    yum clean all && \
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
    useradd -G wheel user
USER user
ENTRYPOINT ["/bin/bash"]
CMD []
