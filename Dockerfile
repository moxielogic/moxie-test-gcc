FROM atgreen/moxielogic-builder-el7-base

MAINTAINER Anthony Green <green@moxielogic.com>

RUN mkdir -p /home/moxie && chmod 777 /home/moxie

ADD Moxie_Logic.repo /etc/yum.repos.d/Moxie_Logic.repo
ADD site.exp /home/moxie/site.exp
ADD moxie-sim.exp /home/moxie/moxie-sim.exp
ADD test_results.patch /home/moxie/test_results.patch

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install git curl jq \
                   patch \
                   autogen \
                   dejagnu \
                   msmtp \
		   wget \
                   ca-certificates \
		   nss\* \
                   moxielogic-moxie-elf-newlib \
                   moxielogic-moxie-elf-binutils \
                   moxielogic-moxie-elf-gdb-sim

RUN mkdir /home/moxie/.ssh && ssh-keyscan github.com > /home/moxie/.ssh/known_hosts
ADD config /home/moxie/.ssh/config

COPY ./moxie-test-gcc.sh /home/moxie/moxie-test-gcc.sh

RUN find /home/moxie | xargs ls -l



