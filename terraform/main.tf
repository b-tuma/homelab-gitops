terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.1"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_api_token_id     = var.proxmox_id
  pm_api_token_secret = var.proxmox_secret
  pm_tls_insecure     = true
  # Give enough time for Ignition to install qemu-guest-agent
  #pm_timeout = 600
}

data "template_file" "user_data" {
  count = var.vm_count
  template = file("${path.module}/template.ign")
  # Ignition variables
  vars = {
    pubkey = var.ssh_key
    hostname = "Node${count.index + 1}"
  }
}

resource "local_file" "ignition_user_data_file" {
  count = var.vm_count
  content = data.template_file.user_data[count.index].rendered
  filename = "${path.module}/ignition/custom_${count.index + 1}.ign"
}

resource "null_resource" "proxmox_ignition_file" {
  count = var.vm_count
  connection {
    type = "ssh"
    user = var.proxmox_user
    password = var.proxmox_password
    host = var.proxmox_host
  }

  provisioner "file" {
    source = local_file.ignition_user_data_file[count.index].filename
    destination = "/tmp/ignition_${count.index + 1}.ign"
  }
}

resource "proxmox_vm_qemu" "kube_server" {
  depends_on = [
    null_resource.proxmox_ignition_file,
  ]

  count       = var.vm_count
  name        = "kube-vm-${count.index + 1}"
  desc        = "Fedora CoreOS VM Kubernetes Node"
  pool        = "Kubernetes"
  target_node = var.proxmox_node
  clone       = var.template_name
  
  onboot = true
  tablet = false
  
  # This parameter will not work without some edits to Proxmox code.
  # See more in proxmox-args-workaround.md
  args      = "-fw_cfg name=opt/com.coreos/config,file=/tmp/ignition_${count.index + 1}.ign"
  agent     = 1
  cores     = 2
  sockets   = 1
  cpu       = "host"
  memory    = 2048
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
