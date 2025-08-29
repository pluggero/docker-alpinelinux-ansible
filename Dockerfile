FROM alpine:latest
LABEL maintainer="Robin Plugge"
ENV container=docker

ENV pip_packages="ansible"

# Install requirements
RUN apk update \
 && apk add --no-cache \
      sudo \
      bash \
      openrc \
      python3 \
      py3-pip \
      py3-yaml \
      py3-cryptography \
      openssh-client \
      sshpass \
      git \
      rsync \
      shadow \
 && rm -rf /var/cache/apk/*

# Install Ansible via Pip with system packages override
RUN pip3 install --break-system-packages --upgrade pip
RUN pip3 install --break-system-packages $pip_packages

# Setup OpenRC
RUN rc-update add local default

# Configure sudo
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Configure sudo access for ansible user with password requirement
RUN echo "ansible ALL=(ALL:ALL) ALL" > /etc/sudoers.d/ansible

# Create ansible user with home directory
RUN useradd -m -s /bin/bash ansible \
    && echo "ansible:ansible" | chpasswd

# Install Ansible inventory file
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_user=ansible ansible_connection=local" > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/sbin/init"]
