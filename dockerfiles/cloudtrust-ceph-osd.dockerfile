FROM cloudtrust-baseimage:f27

ARG ceph_service_git_tag
ARG ceph_tools_git_tag

ARG ceph-osd_version=1:12.2.7-1.fc27
ARG ceph-common_version=1:12.2.7-1.fc27

RUN dnf update -y && \
    dnf install -y ceph-osd-$ceph-osd_version ceph-common-$ceph-common_version && \
    dnf clean all

WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/ceph-tools.git && \
    git clone git@github.com:cloudtrust/ceph-service.git

WORKDIR /cloudtrust/ceph-service
RUN git checkout ${ceph_service_git_tag} && \
    install -v -m644 -o root -g root deploy/etc/systemd/system/ceph-osd.service /etc/systemd/system/ceph-osd.service

WORKDIR /cloudtrust/ceph-tools
RUN git checkout ${ceph_tools_git_tag} && \
    install -d -v -m755 -o ceph -g ceph /cloudtrust/ceph-scripts && \
    install -v -m755 -o ceph -g ceph deploy/cloudtrust/ceph-scripts/osd.sh /cloudtrust/ceph-scripts/osd.sh && \
    systemctl enable ceph-osd.service
