# Fedora CoreOS Worker

data "ct_config" "worker-ignitions" {
  count = var.workers_count

  content  = data.template_file.worker-configs.*.rendered[count.index]
  strict   = true
}

data "template_file" "worker-configs" {
  count = var. workers_count

  template = file("${path.module}/fcc/worker.yaml")
  vars = {
    domain_name            = ""
    cluster_dns_service_ip = ""
    cluster_domain_suffix  = var.cluster_domain_suffix
    node_labels            = ""
    node_taints            = ""
    ssh_authorized_key     = var.ssh_key
    desc = "Kubernetes Worker ${count.index + 1}"
  }
}