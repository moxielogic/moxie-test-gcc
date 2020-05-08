FROM atgreen/moxielogic-builder-el7-base

MAINTAINER Anthony Green <green@moxielogic.com>

ADD Moxie_Logic.repo /etc/yum.repos.d/Moxie_Logic.repo
ADD site.exp /root/site.exp
ADD moxie-sim.exp /root/moxie-sim.exp
ADD test_results.patch /root/test_results.patch

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install git curl jq \
                   patch \
                   autogen \
                   dejagnu \
                   msmtp \
		   wget \
                   ca-certificates \
                   moxielogic-moxie-elf-newlib \
                   moxielogic-moxie-elf-binutils \
                   moxielogic-moxie-elf-gdb-sim

RUN mkdir /root/.ssh && ssh-keyscan github.com > ~/.ssh/known_hosts
ADD config /root/.ssh/config

COPY ./moxie-test-gcc.sh /root/moxie-test-gcc.sh

