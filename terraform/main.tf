terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.0"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_url
  pm_api_token_id     = var.proxmox_id
  pm_api_token_secret = var.proxmox_secret
  pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "kube_server" {
  count       = 1
  name        = "kube-vm-${count.index + 1}"
  desc        = "Rocky Linux VM Kubernetes Node"
  pool        = "Kubernetes"
  target_node = var.proxmox_host
  clone       = var.template_name
  
  onboot = true
  tablet = false
  
  agent     = 1
  os_type   = "cloud-init"
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

  # Fix weirdness with pool name being detected as changed.
  lifecycle {
    ignore_changes = [
      pool,
    ]
  }

  ipconfig0 = "ip=10.50.0.21${count.index + 1}/24,gw=10.50.0.1"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
