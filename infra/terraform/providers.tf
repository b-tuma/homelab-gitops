terraform {
    required_version = ">= 0.13.0, < 2.0.0"
    required_providers {
        template = "~> 2.2"
        null = ">= 3.1"
        
        proxmox = {
            source  = "telmate/proxmox"
            version = "~> 2.9.1"
        }

        ct = {
            source = "poseidon/ct"
            version = "~> 0.9"
        }
    }
}

provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_api_token_id     = var.proxmox_id
  pm_api_token_secret = var.proxmox_secret
  pm_tls_insecure     = true
}

provider "ct" {}