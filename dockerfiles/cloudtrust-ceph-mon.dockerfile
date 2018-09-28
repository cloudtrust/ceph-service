FROM cloudtrust-baseimage:f27

ARG ceph_service_git_tag
ARG config_repo
ARG config_git_tag
ARG ceph_tools_git_tag

ARG ceph-mon_version=1:12.2.7-1.fc27
ARG ceph-common_version=1:12.2.7-1.fc27

RUN dnf update -y && \
    dnf install -y ceph-mon-$ceph-mon_version ceph-common-$ceph-common_version && \
    dnf clean all

WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/ceph-tools.git && \
    git clone git@github.com:cloudtrust/ceph-service.git && \
    git clone ${config_repo} ./config

WORKDIR /cloudtrust/ceph-service
RUN git checkout ${ceph_service_git_tag} && \
    install -v -m644 -o root -g root deploy/etc/systemd/system/ceph-mon.service /etc/systemd/system/ceph-mon.service

WORKDIR /cloudtrust/config
RUN git checkout ${config_git_tag} && \
    install -v -m6444 -o root -g root deploy/etc/systemd/system/ceph_mon_init.service /etc/systemd/system/ceph_mon_init.service

WORKDIR /cloudtrust/ceph-tools
RUN git checkout ${ceph_tools_git_tag} && \
    install -d -v -m755 -o ceph -g ceph /cloudtrust/ceph-scripts && \
    install -v -m755 -o ceph -g ceph deploy/cloudtrust/ceph-scripts/mon.sh /cloudtrust/ceph-scripts/mon.sh && \
    systemctl enable ceph-mon.service && \
    systemctl enable ceph_mon_init.service
