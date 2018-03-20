FROM cloudtrust-baseimage:f27

ARG ceph_service_git_tag
ARG config_repo
ARG config_git_tag
ARG ceph_tools_git_tag

RUN dnf install -y ceph-mon ceph-common

WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/ceph-tools.git && \
    git clone git@github.com:cloudtrust/ceph-service.git && \
    git clone ${config_repo} ./config

WORKDIR /cloudtrust/ceph-service
RUN git checkout ${ceph_service_git_tag} && \
    install -v -m644 -o root -g root deploy/etc/systemd/system/ceph-mon.service /etc/systemd/system/ceph-mon.service

WORKDIR /cloudtrust/config
RUN install -v -m6444 -o root -g root deploy/etc/systemd/system/ceph_mon_init.service /etc/systemd/system/ceph_mon_init.service

WORKDIR /cloudtrust/ceph-tools
RUN git checkout ${ceph_tools_git_tag} && \
    rm -rf /etc/sysconfig/ceph && \
    install -v -m644 -d -o ceph -g ceph /etc/sysconfig/ceph && \ 
    install -v -m644 -o ceph -g ceph deploy/etc/sysconfig/ceph/ceph-mon /etc/sysconfig/ceph/ceph-mon && \
    install -v -m755 -o ceph -g ceph deploy/etc/sysconfig/ceph/mon.sh /etc/sysconfig/ceph/mon.sh && \
    systemctl enable ceph-mon.service && \
    systemctl enable ceph_mon_init.service
