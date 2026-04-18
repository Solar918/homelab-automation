variable "name"             { type = string }
variable "ctid"             { type = number }          # container ID (like VMID, but for CT)
variable "node"             { type = string }
variable "pool_id"          {
				type = string
				default = "default"
				}

variable "template_storage" { type = string }          # e.g., "local" (where the tarball lives)
variable "template_file_id" { type = string }          # e.g., "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"

variable "datastore"        { type = string }          # rootfs storage, e.g., "local-lvm"
variable "rootfs_gb"        { 
				type = number
				default = 8
				}

variable "cores"            {
				type = number
				default = 2
				}
variable "memory_mb"        {
				type = number
				default = 1024
				}

variable "swap_mb"          {
                                type = number
                                default = 1024
                                }

variable "bridge"           {
				type = string
				default = "vmbr0"
				}
variable "vlan_id"          {
				type = number
				default = null
				}
variable "ipv4_cidr"        {
				type = string
				default = "dhcp"
				}  # or "192.168.10.15/24"
variable "gateway"          {
				type = string
				default = "192.168.68.1"
				}

variable "unprivileged"     {
				type = bool
				default = true
				}

variable "nesting"          {
				type = bool
				default = false
				}

variable "os_type"          {
                                type = string
                                default = "ubuntu"
                                }

variable "dns_domain" {
  description = "Search domain for the CT"
  type        = string
  default     = "localdomain"
}

variable "dns_servers" {
  description = "List of DNS servers. If empty, dns block is omitted"
  type        = list(string)
  default     = []
}

variable "ssh_public_keys"  {
                                type = string
                            }           # your SSH pubkey(s), one per line

variable "tags"             {
                                type = list(string)
                                default = []
                                }

variable "groups" {
  description = "Optional Ansible groups this CT should belong to (e.g., [\"docker_hosts\", \"twingate\"])"
  type        = list(string)
  default     = []
}

variable "ssh_keys" {
  description = "List of public key lines to authorize for root inside the LXC."
  type        = list(string)
  default     = []
}

variable "ssh_key_files" {
  description = "List of filesystem paths to public key files; contents will be read and authorized for root."
  type        = list(string)
  default     = []
}

variable "binds" {
  description = "Bind mounts to add to this CT (host share name + target path + optional mp index)"
  type = list(object({
    share    = string               # e.g., "data" or "media"
    ct_path  = string               # e.g., "/mnt/data"
    mp_index = optional(number)     # optional fixed mp slot
  }))
  default = []
}
