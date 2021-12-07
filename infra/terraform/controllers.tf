# Fedora CoreOS Controller

# Generate Proxmox VM for controllers
resource "proxmox_vm_qemu" "controllers" {
    depends_on = [
      null_resource.proxmox_controller_configs,
    ]
    
    count = var.controllers_count

    name = "kube-controller-${count.index + 1}"
    desc = "Fedora CoreOS - Kubernetes Controller ${count.index + 1}"
    pool = "Kubernetes"
    target_node = var.proxmox_node
    clone = var.template_name

    onboot = true
    tablet = false

    # The args parameter will not work without some edits to Proxmox code.
    # See more in proxmox-args-workaround.md
    args = "-fw_cfg name=opt/com.coreos/config,file=/tmp/controller_ignition_${count.index + 1}.ign"
    agent = 1
    cores = 2
    sockets = 1
    cpu = "host"
    memory = 2048
    scsihw    = "virtio-scsi-pci"
    bootdisk  = "scsi0"
    
    disk {
        slot     = 0
        size     = "10G"
        type     = "scsi"
        storage  = "local-lvm"
        iothread = 1
    }

    network {
        model  = "virtio"
        bridge = "vmbr0"
    }

    timeouts {
        create = "5m"
        delete = "1m"
    }

    # Fix weirdness with pool name being detected as changed.
    lifecycle {
        ignore_changes = [
        pool,
        ]
    }
}

# Send Ignition file to Proxmox server
resource "null_resource" "proxmox_controller_configs" {
  count = var.controllers_count

  connection {
    type = "ssh"
    user = var.proxmox_user
    password = var.proxmox_password
    host = var.proxmox_host
  }

  provisioner "file" {
    content = data.ct_config.controller-ignitions.*.rendered[count.index]
    destination = "/tmp/controller_ignition_${count.index + 1}.ign"
  }
}

# Controller config converted to Ignition
data "ct_config" "controller-ignitions" {
    count = var.controllers_count

    content = data.template_file.controller-configs.*.rendered[count.index]
    strict = true
}

# Controller Butane config
data "template_file" "controller-configs" {
  count = var.controllers_count

  template = file("${path.module}/fcc/controller.yaml")
  vars = {
    domain_name = "nodec${count.index + 1}.${var.domain_name}"
    etcd_name = "nodec${count.index + 1}"
    etcd_initial_cluster = join(",", data.template_file.etcds.*.rendered)
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix = var.cluster_domain_suffix
    ssh_authorized_key = var.ssh_key
    desc = "Kubernetes Controller ${count.index + 1}"
  }
}

data "template_file" "etcds" {
  count = var.controllers_count
  template = "$${etcd}=https://$${domain}:2380"

  vars = {
    etcd   = "nodec${count.index + 1}"
    domain = "nodec${count.index + 1}.${var.domain_name}"
  }
}