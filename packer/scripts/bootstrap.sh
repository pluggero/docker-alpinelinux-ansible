#!/bin/sh
# Bootstrap script to install base packages and Python for Ansible provisioning
set -euo pipefail

export container=docker

# Update package lists and install base packages
apk update
apk add --no-cache \
    sudo \
    python3
