#output "vm_id" {
#  value = module.example_vm.id
#}


locals {
  ct_keys_map = {
    for ct in var.cts :
    ct.name => (length(try(ct.ssh_keys, [])) > 0 || length(try(ct.ssh_key_files, [])) > 0)
  }
}

# Map of CT name -> IPv4 (only if statically set, not "dhcp")
output "ct_ips" {
  description = "IPv4 per container (static only)"
  value = {
    for name, m in module.cts :
    name => m.ipv4
    if m.ipv4 != null
  }
}

# Ansible inventory (YAML string you can write to a file with `terraform output -raw`)
output "ct_ansible_inventory_yaml" {
  value = yamlencode({
    all = {
      vars = {
        ansible_user               = "ethan"
        ansible_become             = true
        ansible_become_method      = "sudo"
        ansible_python_interpreter = "/usr/bin/python3"
      }
      hosts = {
        for name, m in module.cts :
        name => {
          ansible_host = m.ipv4
        }
        if try(m.ipv4, null) != null
      }
    }

    docker_hosts = {
      hosts = {
        for name, m in module.cts :
        name => {}
        if can(m.groups) && contains(m.groups, "docker_hosts")
      }
    }
  })
}


# CTs that need host-side LXC feature tweaks
# - keyctl/nesting only for docker_hosts
# - /dev/net/tun for explicit needs_tun
output "ct_feature_requests" {
  value = [
    for name, m in module.cts : {
      name         = name
      ctid         = m.ctid
      node         = m.node
      needs_keyctl = contains(try(m.groups, []), "docker_hosts")
      needs_tun = contains(try(m.groups, []), "needs_tun")
      has_keys = try(local.ct_keys_map[name], false)
    }
  ]
}



# TEMP: what cts the root module sees
output "debug_var_cts" {
  value = var.cts
}

# TEMP: what our has_keys detector sees
output "debug_ct_keys_map" {
  value = {
    for ct in var.cts :
    ct.name => (length(try(ct.ssh_keys, [])) > 0 || length(try(ct.ssh_key_files, [])) > 0)
  }
}


# Maps CT bind intents → one JSON array Ansible can consume
output "ct_bind_mounts" {
  value = flatten([
    for name, m in module.cts : [
      for b in m.binds : {
        name     = name
        ctid     = m.ctid
        node     = m.node
        share    = b.share
        ct_path  = b.ct_path
        mp_index = try(b.mp_index, null)
      }
    ]
  ])
}
