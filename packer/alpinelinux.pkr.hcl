##################################################################################
# SOURCES
##################################################################################

source "docker" "alpinelinux" {
  image  = "alpine:latest"
  commit = true
  changes = [
    "LABEL maintainer=\"${var.maintainer}\"",
    "VOLUME [\"/sys/fs/cgroup\"]",
    "CMD [\"/sbin/init\"]"
  ]
}

##################################################################################
# BUILD
##################################################################################

build {
  sources = ["source.docker.alpinelinux"]

  provisioner "shell" {
    script = "${path.root}/scripts/bootstrap.sh"
  }

  provisioner "ansible" {
    user                 = "${var.ansible_user}"
    galaxy_file          = "${path.root}/../ansible/requirements.yml"
    galaxy_force_install = true
    roles_path           = "${path.root}/../ansible/roles"
    playbook_file        = "${path.root}/../ansible/playbooks/main.yml"
    ansible_env_vars = [
      # To enable piplining, you have to edit sudoers file
      # See:https://docs.ansible.com/ansible/latest/reference_appendices/config.html#ansible-pipelining
      # "ANSIBLE_PIPELINING=true",
      "ANSIBLE_ROLES_PATH=${path.root}/../ansible/roles",
      "ANSIBLE_FORCE_COLOR=true",
      "ANSIBLE_HOST_KEY_CHECKING=false",
    ]
  }

  provisioner "shell" {
    script = "${path.root}/scripts/cleanup.sh"
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "${var.docker_registry}/${var.image_name}"
      tags       = [local.image_tag]
    }

    post-processor "docker-save" {
      path = "${path.root}/outputs/alpinelinux-ansible.tar"
    }
  }
}
