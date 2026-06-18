resource "proxmox_download_file" "ubuntu" {
  content_type        = "iso"
  datastore_id        = "local"
  node_name           = var.proxmox_node
  url                 = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  file_name           = "ubuntu-22.04-cloud.img"
  overwrite_unmanaged = true
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.vm_name
  node_name = var.proxmox_node

  cpu {
    cores = 4
    type  = "kvm64"
  }

  memory {
    dedicated = 8192
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "vmstorage"
    file_id      = proxmox_download_file.ubuntu.id
    interface    = "scsi0"
    size         = 20
  }

  operating_system {
    type = "l26"
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.vm_ip
        gateway = var.vm_gateway
      }
    }

    user_account {
      username = var.vm_user
      keys     = [var.ssh_public_key]
    }
  }
}
