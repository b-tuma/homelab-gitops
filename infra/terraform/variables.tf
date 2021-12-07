variable "proxmox_node"{
  type    = string
  default = "node"
}

variable "proxmox_host" {
  type    = string
  default = "host"
}

variable "ssh_key" {
  type    = string
  default = "ssh-rsa AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA me@mypc" 
}

variable "template_name" {
  type    = string
  default = "linux-template"
}

variable "proxmox_id" {
  type    = string
  default = "proxmox@proxmox"
}

variable "proxmox_secret" {
  type    = string
  default = "12345678-1234-1234-1234-0123456789ab"
}

variable "proxmox_user" {
  type    = string
  default = "proxmox"
}

variable "proxmox_password" {
  type    = string
  default = "password"
}

variable "controllers_count" {
  type    = number
  default = 1
}

variable "workers_count" {
  type    = number
  default = 1
}

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = string
  default     = "cluster.local"
}

# configuration

variable "k8s_domain_name" {
  description = "Controller DNS name which resolves to a controller instance. Workers and kubeconfig's will communicate with this endpoint (e.g. cluster.example.com)"
  type        = string
}

variable "domain_name" {
  type        = string
}

variable "networking" {
  description = "Choice of networking provider (flannel or calico)"
  type        = string
  default     = "calico"
}

variable "network_mtu" {
  description = "CNI interface MTU (applies to calico only)"
  type        = number
  default     = 1480
}

variable "network_ip_autodetection_method" {
  description = "Method to autodetect the host IPv4 address (applies to calico only)"
  type        = string
  default     = "first-found"
}

variable "pod_cidr" {
  description = "CIDR IPv4 range to assign Kubernetes pods"
  type        = string
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
    CIDR IPv4 range to assign Kubernetes services.
    The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
    EOD
  type        = string
  default     = "10.3.0.0/16"
}

variable "cluster_name" {
  description = "Unique cluster name"
  type        = string
}

# optional

variable "enable_reporting" {
  description = "Enable usage or analytics reporting to upstreams (Calico)"
  type        = bool
  default     = false
}

variable "enable_aggregation" {
  description = "Enable the Kubernetes Aggregation Layer (defaults to false)"
  type        = bool
  default     = false
}