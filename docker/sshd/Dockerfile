# Build Ubuntu image with base functionality.
FROM ubuntu:focal AS ubuntu-base

# OpenSSH Version to install
# See versions available here: https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/
ARG OPENSSH_VERSION=8.8p1

ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup the default user.
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo ubuntu
RUN echo 'ubuntu:ubuntu' | chpasswd
USER ubuntu
WORKDIR /home/ubuntu


# Build image with Python and SSHD.
FROM ubuntu-base AS ubuntu-with-sshd
USER root

# Install required tools.
RUN apt-get -qq update \
    && apt-get -qq --no-install-recommends install vim-tiny=2:8.1.* \
    && apt-get -qq --no-install-recommends install sudo=1.8.* \
    && apt-get -qq --no-install-recommends install python3-pip=20.0.* \
    && apt-get -qq --no-install-recommends install build-essential zlib1g-dev libssl-dev wget

# Get OpenSSH package
RUN wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${OPENSSH_VERSION}.tar.gz

# Install OpenSSH from tar archive
RUN tar -xvf ./openssh-${OPENSSH_VERSION}.tar.gz

RUN cd openssh-${OPENSSH_VERSION} && install  -v -m700 -d /var/lib/sshd \
        && chown -v root:sys /var/lib/sshd \
        && groupadd -g 51 sshd \
        && useradd  -c 'sshd PrivSep' -d /var/lib/sshd -g sshd -s /bin/false -u 51 sshd \
        && ./configure --prefix=/usr \
            --sysconfdir=/etc/ssh \
            --with-md5-passwords \
            --with-privsep-path=/var/lib/sshd \
            --with-default-path=/usr/bin \
            --with-superuser-path=/usr/sbin:/usr/bin \
            --with-pid-dir=/run \
        && make \
        && make install \
        && install -v -m755 contrib/ssh-copy-id /usr/bin \
        && install -v -m644    contrib/ssh-copy-id.1 /usr/share/man/man1 \
        && install -v -m755 -d /usr/share/doc/openssh-8.8p1 \
        && install -v -m644    INSTALL LICENCE OVERVIEW README* /usr/share/doc/openssh-8.8p1

RUN apt-get --purge autoremove build-essential zlib1g-dev libssl-dev wget -y \
    && apt-get -qq clean    \
    && rm -rf /var/lib/apt/lists/*

# Clean up files
RUN rm -rf openssh-${OPENSSH_VERSION} ./openssh-${OPENSSH_VERSION}.tar.gz

# Copy in sshd_config from ./files directory
COPY --chown=ubuntu:root "./files/sshd_config" /etc/ssh/sshd_config

# Configure sudo.
RUN ex +"%s/^%sudo.*$/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/g" -scwq! /etc/sudoers

# Add CA public key to authorized_keys file
COPY --chown=ubuntu:root "./files/authorized_keys" /home/ubuntu/.ssh/authorized_keys
RUN sudo chmod 600 /home/ubuntu/.ssh/authorized_keys

# Setup default command and/or parameters.
EXPOSE 22
CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]

# Testing override of command:
# /usr/bin/sudo /usr/sbin/sshd -D -o ListenAddress=0.0.0.0
# CMD ["/usr/bin/sleep", "infinity"]