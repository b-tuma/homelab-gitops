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

variable "vm_count" {
  default = 1
}