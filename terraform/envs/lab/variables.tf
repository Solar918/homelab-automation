variable "pm_api_url" { type = string }
variable "pm_user" { type = string }
variable "pm_token_name" {
  type = string
}
variable "pm_token_value" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  type    = string
  default = ""
}


variable "cts" {
  description = "LXC containers to create"
  type = list(object({
    name         = string
    ctid         = number
    pool_id      = string
    ostype       = string
    node         = string
    datastore    = string
    rootfs_gb    = number
    cores        = number
    memory_mb    = number
    swap_mb      = number
    bridge       = string
    vlan_id      = number
    ipv4_cidr    = string
    gateway      = string
    unprivileged = bool
    nesting      = bool
    groups       = optional(list(string), [])
    ssh_key_files = optional(list(string), [])
    binds        = optional(list(object({
                    share     = string
                    ct_path   = string
                    mp_index  = optional(number)
                   })),[])
  }))
  default = []
}

