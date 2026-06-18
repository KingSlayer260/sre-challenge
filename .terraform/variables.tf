variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_ssh_private_key" {
  type      = string
  sensitive = true
}

variable "vm_name" {
  type = string
}

variable "vm_ip" {
  type = string # include prefix e.g. 192.168.1.100/24
}

variable "vm_gateway" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "vm_user" {
  type = string
}

variable "vm_memory" {
  type = number
}

variable "vm_cpus" {
  type = number
}
