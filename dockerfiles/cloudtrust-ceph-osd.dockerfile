FROM cloudtrust-baseimage:f27

ARG ceph_service_git_tag
ARG ceph_tools_git_tag

RUN dnf install -y ceph-osd ceph-common

WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/ceph-tools.git && \
    git clone git@github.com:cloudtrust/ceph-service.git

WORKDIR /cloudtrust/ceph-service
RUN git checkout ${ceph_service_git_tag} && \
    install -v -m644 -o root -g root deploy/etc/systemd/system/ceph-osd.service /etc/systemd/system/ceph-osd.service

WORKDIR /cloudtrust/ceph-tools
RUN git checkout ${ceph_tools_git_tag} && \
    rm -rf /etc/sysconfig/ceph && \
    install -v -m644 -d -o ceph -g ceph /etc/sysconfig/ceph && \ 
    install -v -m644 -o ceph -g ceph deploy/etc/sysconfig/ceph/ceph-osd /etc/sysconfig/ceph/ceph-osd && \
    install -v -m755 -o ceph -g ceph deploy/etc/sysconfig/ceph/osd.sh /etc/sysconfig/ceph/osd.sh && \
    systemctl enable ceph-osd.service
