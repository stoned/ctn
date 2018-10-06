FROM centos:7.5.1804
RUN yum install -y bind-utils && \
    yum clean all && \
    useradd user
USER user
ENTRYPOINT ["/bin/bash"]
CMD []
