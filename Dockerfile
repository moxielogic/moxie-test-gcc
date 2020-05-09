FROM atgreen/moxielogic-builder-el7-base

MAINTAINER Anthony Green <green@moxielogic.com>

ENV USER_NAME=moxie \
    USER_UID=10001 \
    HOME=/home/moxie

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install git curl jq \
                   patch \
                   autogen \
                   dejagnu \
                   msmtp \
		   wget \
                   ca-certificates \
		   nss_wrapper \
                   moxielogic-moxie-elf-newlib \
                   moxielogic-moxie-elf-binutils \
                   moxielogic-moxie-elf-gdb-sim

RUN mkdir -p /home/moxie /home/moxie/etc
RUN chmod -R ug+x /home/moxie && sync && \
    useradd -l -u ${USER_UID} -r -g 0 -d /home/moxie -s /sbin/nologin -c "${USER_NAME} user" ${USER_NAME} 

ADD Moxie_Logic.repo /etc/yum.repos.d/Moxie_Logic.repo
ADD site.exp /home/moxie/site.exp
ADD moxie-sim.exp /home/moxie/moxie-sim.exp
ADD test_results.patch /home/moxie/test_results.patch

RUN mkdir /home/moxie/.ssh && ssh-keyscan github.com > /home/moxie/.ssh/known_hosts
ADD config /home/moxie/.ssh/config

COPY ./moxie-test-gcc.sh /home/moxie/moxie-test-gcc.sh

RUN chown -R ${USER_UID}:0 /home/moxie && \
    chmod -R g=u /home/moxie

USER 10001
WORKDIR /home/moxie

RUN curl --verbose https://google.com

### NSS_WRAPPER for user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
RUN sed "s@${USER_NAME}:x:${USER_UID}:0@${USER_NAME}:x:\${USER_ID}:\${GROUP_ID}@g" /etc/passwd > /home/moxie/etc/passwd.template
ENTRYPOINT [ "nss_entrypoint" ]
CMD run
