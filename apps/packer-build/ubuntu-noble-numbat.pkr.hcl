# Ubuntu Server Noble
# ---
# Packer Template to create an Ubuntu Server (noble) on Proxmox
packer {
  required_plugins {
    proxmox = {
      version = " >= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu-noble-numbat" {

  # Proxmox Connection Settings
  proxmox_url = "${var.proxmox_api_url}"
  username    = "${var.proxmox_api_token_id}"
  token       = "${var.proxmox_api_token_secret}"
  # (Optional) Skip TLS Verification
  insecure_skip_tls_verify = true

  # VM General Settings
  # node = "your-proxmox-node"
  node = "pve"
  # vm_id = "100"
  vm_name              = "auto-ubuntu-24-04"
  template_name        = "p4-large"
  template_description = "packer generated p4-large ubuntu-24.04.1-server-amd64"

  # VM OS Settings
  # (Option 1) Local ISO File
  # - or -
  # (Option 2) Download ISO
  # iso_url = "https://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso"
  # iso_checksum = "84aeaf7823c8c61baa0ae862d0a06b03409394800000b3235854a6b38eb4856f"

  boot_iso {
    type = "scsi"
    iso_file = "local:iso/ubuntu-24.04.1-live-server-amd64.iso"
    iso_checksum = "e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
    unmount = true
  }

  # VM System Settings
  qemu_agent = true

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size    = "128G"
    format       = "raw"
    storage_pool = "fast-storage"
    type         = "scsi"
  }

  # VM CPU Settings
  cores = "4"

  # VM Memory Settings
  memory = "8192"

  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # PACKER Boot Commands
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot      = "c"
  boot_wait = "5s"

  # PACKER Autoinstall Settings
  http_directory = "http"
  # (Optional) Bind IP Address and Port, IP should be running vm and 8802 should be accessible via firewall
  http_bind_address = "10.0.0.16"
  http_port_min     = 8802
  http_port_max     = 8802

  # (Option 1) Add your Password here
  ssh_username = "ubuntu"
  ssh_password = "password"
  # - or -
  # (Option 2) Add your Private SSH KEY file here
  ssh_private_key_file = "~/.ssh/lxc"

  # Raise the timeout, when installation takes longer
  ssh_timeout            = "10m"
  ssh_handshake_attempts = "500"
  ssh_pty                = true
}

# Build Definition to create the VM Template
build {

  name    = "ubuntu-noble-numbat"
  sources = ["source.proxmox-iso.ubuntu-noble-numbat"]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }

  # Add additional provisioning scripts here
  # ...
}