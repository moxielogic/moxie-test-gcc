FROM atgreen/moxielogic-builder-el7-base

MAINTAINER Anthony Green <green@moxielogic.com>

ENV USER_NAME=moxie \
    USER_UID=10001 \
    HOME=/home/moxie

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -ivh https://repos.moxielogic.org:7007/MoxieLogic/noarch/moxielogic-repo-latest.noarch.rpm && \
    yum -y install git curl jq \
                   patch \
                   autogen \
                   dejagnu \
                   msmtp \
                   wget \
                   ca-certificates \
                   moxielogic-moxie-elf-newlib \
                   moxielogic-moxie-elf-binutils \
                   moxielogic-moxie-elf-gdb-sim && \
    yum -y update


RUN mkdir -p /home/moxie /home/moxie/etc
RUN chmod -R ug+x /home/moxie && sync && \
    useradd -l -u ${USER_UID} -r -g 0 -d /home/moxie -s /sbin/nologin -c "${USER_NAME} user" ${USER_NAME}

ADD Moxie_Logic.repo /etc/yum.repos.d/Moxie_Logic.repo
ADD site.exp /home/moxie/site.exp
ADD moxie-sim.exp /home/moxie/moxie-sim.exp
ADD test_results.patch /home/moxie/test_results.patch

RUN mkdir /home/moxie/.ssh && ssh-keyscan github.com > /home/moxie/.ssh/known_hosts
ADD config /home/moxie/.ssh/config
RUN chmod 644 /home/moxie/.ssh/config

COPY ./moxie-test-gcc.sh /home/moxie/moxie-test-gcc.sh

RUN chown -R ${USER_UID}:0 /home/moxie && \
    chmod -R g=u /home/moxie

USER 10001
WORKDIR /home/moxie

CMD bash -c "while true; do sleep 5000; done;"
