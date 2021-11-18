variable "proxmox_node"{
  default = "node"
}

variable "proxmox_host" {
  default = "host"
}

variable "ssh_key" {
  default = "ssh-rsa AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA me@mypc" 
}

variable "template_name" {
  default = "linux-template"
}

variable "proxmox_id" {
  default = "proxmox@proxmox"
}

variable "proxmox_secret" {
  default = "12345678-1234-1234-1234-0123456789ab"
}

variable "proxmox_user" {
  default = "proxmox"
}

variable "proxmox_password" {
  default = "password"
}

variable "vm_count" {
  default = 1
}

variable "controllers_count" {
  default = 1
}

variable "workers_count" {
  default = 1
}

variable "snippets" {
  type        = map(list(string))
  description = "Map from machine names to lists of Butane snippets"
  default     = {}
}

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = string
  default     = "cluster.local"
}