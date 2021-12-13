FROM ubuntu:18.04
LABEL Description="ssh-cert-authority"

# OpenSSH Version to install
# See versions available here: https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/
ARG OPENSSH_VERSION=8.8p1

RUN apt-get update \
    && apt-get -qq --no-install-recommends install build-essential zlib1g-dev libssl-dev wget

# Copy ssh-cert-authority binary archive into docker image
COPY ssh-cert-authority-linux-amd64.gz /usr/local/bin/ssh-cert-authority.gz
# Copy assh binary into docker image
COPY assh /usr/local/bin/assh

# Get OpenSSH package
RUN wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${OPENSSH_VERSION}.tar.gz --no-check-certificate

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

# Clean up no longer required dependencies
RUN apt-get --purge autoremove build-essential zlib1g-dev libssl-dev wget -y \
    && apt-get -qq clean    \
    && rm -rf /var/lib/apt/lists/*

# Clean up files
RUN rm -rf openssh-${OPENSSH_VERSION} ./openssh-${OPENSSH_VERSION}.tar.gz

COPY start.sh /usr/local/bin/start.sh

RUN gunzip /usr/local/bin/ssh-cert-authority.gz
RUN chmod +x /usr/local/bin/ssh-cert-authority

CMD ["/bin/bash", "/usr/local/bin/start.sh"]