locals {
  # format assets for distribution
  assets_bundle = [
    # header with the unpack location
    for key, value in module.bootstrap.assets_dist :
    format("##### %s\n%s", key, value)
  ]
}

# Secure copy assets to controllers. Activates kubelet.service
resource "null_resource" "copy-controller-secrets" {
  count = var.controllers_count
  
  depends_on = [
    module.bootstrap,
  ]

  connection {
    type    = "ssh"
    host    = "nodec${count.index + 1}.${var.domain_name}"
    user    = "core"
    timeout = "15m"
    agent = false
    private_key = "${file("${var.ssh_priv}")}"
  }

  provisioner "file" {
    content     = module.bootstrap.kubeconfig-kubelet
    destination = "$HOME/kubeconfig"
  }

  provisioner "file" {
    content     = join("\n", local.assets_bundle)
    destination = "$HOME/assets"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv $HOME/kubeconfig /etc/kubernetes/kubeconfig",
      "sudo touch /etc/kubernetes",
      "sudo /opt/bootstrap/layout",
    ]
  }
}


# Connect to a controller to perform one-time cluster bootstrap.
resource "null_resource" "bootstrap" {
  # Without depends_on, this remote-exec may start before the kubeconfig copy.
  # Terraform only does one task at a time, so it would try to bootstrap
  # while no Kubelets are running.
  depends_on = [
    null_resource.copy-controller-secrets
  ]

  connection {
    type    = "ssh"
    host    = "nodec1.${var.domain_name}"
    user    = "core"
    timeout = "15m"
    agent = false
    private_key = "${file("${var.ssh_priv}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start bootstrap",
    ]
  }
}
