locals {
  # read any files → lines, trim whitespace
  _ssh_keys_from_files = [
    for f in var.ssh_key_files : trimspace(file(pathexpand(f)))
  ]

  # final list: explicit keys win; else keys from files; else empty
  _ssh_keys_final = length(var.ssh_keys) > 0 ? var.ssh_keys : local._ssh_keys_from_files

  # provider wants a single newline-separated string
  _ssh_keys_string = length(local._ssh_keys_final) > 0 ? trimspace(join("\n", local._ssh_keys_final)) : null
}

resource "proxmox_virtual_environment_container" "this" {
  vm_id     = var.ctid
  node_name = var.node
  pool_id   = var.pool_id

  description = "Managed by Terraform"

  # template tarball to clone
  operating_system {
    template_file_id = var.template_file_id           # e.g., "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type = var.os_type
  }

  # root filesystem
  disk {
    datastore_id = var.datastore             # e.g., "local-lvm"
    size         = var.rootfs_gb
  }

  # resources
  cpu    { cores     = var.cores }
  memory {
    dedicated = var.memory_mb
    swap      = var.swap_mb
  }

  # security/features
  unprivileged = var.unprivileged
  features {
    nesting = var.nesting
  }

  start_on_boot = true
  started       = false

  lifecycle {
    ignore_changes = [
      started,
      features[0].keyctl,
      features[0].nesting
    ]
  }

  # network
  network_interface {
    name   = "eth0"
    bridge = var.bridge
    vlan_id = var.vlan_id
  }

  initialization {
    
    ip_config {
      ipv4 {
        address = var.ipv4_cidr
        gateway = var.gateway
      }
    }

    hostname = var.name

#    dns {
#      domain = try(var.dns_domain, "localdomain")
#      servers = try(var.dns_servers, [])
#    }

    dynamic "dns" {
      for_each = (length(var.dns_servers) > 0) ? [1] : []
      content {
        domain  = var.dns_domain
        servers = var.dns_servers      # ← plural
      }
}

#    user_account {
#      keys = local._ssh_keys_final
#    }

    dynamic "user_account" {
      for_each = length(local._ssh_keys_final) > 0 ? [1] : []
      content {
        keys = local._ssh_keys_final
      }
}
    
  }
}
