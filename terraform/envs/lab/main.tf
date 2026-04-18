terraform {
  required_version = ">= 1.3.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.65.0"
    }
  }
  backend "local" {}
}

locals {
  pm_api_token = "${var.pm_user}!${var.pm_token_name}=${var.pm_token_value}"
}

provider "proxmox" {
  endpoint  = var.pm_api_url
  api_token = local.pm_api_token
  insecure  = true
}

#module "example_vm" {
#  source = "../../modules/vm"
#  name   = "example-vm"
#  pool   = "default"
#  vmid   = 101
#  node   = "proxmox01"
#  memory = 512
#  cores  = 2
#}


module "cts" {
  source   = "../../modules/ct"
  for_each = { for c in var.cts : c.name => c }

  name    = each.value.name
  ctid    = each.value.ctid
  node    = each.value.node
  pool_id = each.value.pool_id

  template_storage = "local"
  template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  os_type          = each.value.ostype

  datastore = each.value.datastore
  rootfs_gb = each.value.rootfs_gb
  cores     = each.value.cores
  memory_mb = each.value.memory_mb
  swap_mb   = each.value.swap_mb

  bridge    = each.value.bridge
  vlan_id   = each.value.vlan_id
  ipv4_cidr = each.value.ipv4_cidr
  gateway   = each.value.gateway

  unprivileged = each.value.unprivileged
  nesting      = each.value.nesting

  groups = try(each.value.groups, [])

  #dns_domain        = null  #each.value.dns_domain
  #dns_server        = null  #each.value.dns_server

  ssh_public_keys = var.ssh_public_key
  ssh_key_files   = try(each.value.ssh_key_files, [])

  binds           = lookup(each.value, "binds", [])
}
