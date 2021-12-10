output "kubeconfig-admin" {
  value     = module.bootstrap.kubeconfig-admin
  sensitive = true
}

resource "local_file" "kubeconfig" {
  content  = module.bootstrap.kubeconfig-admin
  filename = var.kubeconfig_file
}