# Fedora CoreOS WOrker

# Generate Proxmox VM for workers
resource "proxmox_vm_qemu" "workers" {
    depends_on = [
      null_resource.proxmox_worker_configs,
    ]
    
    count = var.workers_count

    name = "kube-worker-${count.index + 1}"
    desc = "Fedora CoreOS - Kubernetes Worker ${count.index + 1}"
    pool = "Kubernetes"
    target_node = var.proxmox_node
    clone = var.template_name

    onboot = true
    tablet = false

    # The args parameter will not work without some edits to Proxmox code.
    # See more in proxmox-args-workaround.md
    args = "-fw_cfg name=opt/com.coreos/config,file=/tmp/worker_ignition_${count.index + 1}.ign"
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
resource "null_resource" "proxmox_worker_configs" {
  count = var.workers_count

  connection {
    type = "ssh"
    user = var.proxmox_user
    password = var.proxmox_password
    host = var.proxmox_host
  }

  provisioner "file" {
    content = data.ct_config.worker-ignitions.*.rendered[count.index]
    destination = "/tmp/worker_ignition_${count.index + 1}.ign"
  }
}

# Worker config converted to Ignition
data "ct_config" "worker-ignitions" {
    count = var.workers_count

    content = data.template_file.worker-configs.*.rendered[count.index]
    strict = true
}

# Worker Butane config
data "template_file" "worker-configs" {
  count = var.workers_count

  template = file("${path.module}/fcc/worker.yaml")
  vars = {
    domain_name = "nodew${count.index + 1}.${var.domain_name}"
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix = var.cluster_domain_suffix
    ssh_authorized_key = var.ssh_key
    desc = "Kubernetes Worker ${count.index + 1}"
    node_labels = join(",", lookup(var.worker_node_labels, "nodew${count.index + 1}", []))
    node_taints = join(",", lookup(var.worker_node_taints, "nodew${count.index + 1}", []))
  }
}