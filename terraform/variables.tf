variable "proxmox_host" {
  default = "host"
}

variable "ssh_key" {
  default = "ssh-rsa AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA me@mypc" 
}

variable "template_name" {
  default = "linux-template"
}

variable "proxmox_url" {
  default = "https://proxmox.my.home.network:8006/api2/json"
}

variable "proxmox_id" {
  default = "proxmox@proxmox"
}

variable "proxmox_secret" {
  default = "12345678-1234-1234-1234-0123456789ab"
}
