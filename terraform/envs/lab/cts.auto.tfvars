cts = [
  {
    name        = "Cockpit01"
    ostype      = "ubuntu"
    ctid        = 210
    node        = "proxmox01"
    pool_id     = "default"
    datastore   = "flash"
    rootfs_gb   = 16
    cores       = 1
    memory_mb   = 2048
    swap_mb     = 2048
    bridge      = "vmbr0"
    vlan_id     = 0
    ipv4_cidr   = "192.168.68.210/24"
    gateway     = "192.168.68.1"
    unprivileged = true
    nesting     = true
    groups      = ["cockpit"]   # not a docker_host
    binds = []
    ssh_key_files = [
      "~/.ssh/id_ed25519.pub"
    ]
  },

  {
    name        = "Crafty-Controller"
    ostype      = "ubuntu"
    ctid        = 211
    node        = "proxmox01"
    pool_id     = "default"
    datastore   = "flash"
    rootfs_gb   = 64
    cores       = 4
    memory_mb   = 16384
    swap_mb     = 0
    bridge      = "vmbr0"
    vlan_id     = 0
    ipv4_cidr   = "192.168.68.211/24"
    gateway     = "192.168.68.1"
    unprivileged = true
    nesting     = true
    groups      = ["docker_hosts","crafty","needs_tun"]  # docker + optional TUN if you ever need it
    binds = [
      { share = "data",  ct_path = "/mnt/data"  },   # auto mp index
    ]
    ssh_key_files = [
      "~/.ssh/id_ed25519.pub"
    ]
  },

  {
    name        = "Plex"
    ostype      = "ubuntu"
    ctid        = 212
    node        = "proxmox01"
    pool_id     = "default"
    datastore   = "flash"
    rootfs_gb   = 64
    cores       = 4
    memory_mb   = 8096
    swap_mb     = 2048
    bridge      = "vmbr0"
    vlan_id     = 0
    ipv4_cidr   = "192.168.68.212/24"
    gateway     = "192.168.68.1"
    unprivileged = false
    nesting     = false
    groups      = ["docker_hosts","plex","media_stack"]
    binds = [
      { share = "media", ct_path = "/mnt/media" }    # auto mp index
    ]
    ssh_key_files = [
      "~/.ssh/id_ed25519.pub"
    ]
  },

  {
    name        = "qBitTorrent"
    ostype      = "ubuntu"
    ctid        = 213
    node        = "proxmox01"
    pool_id     = "default"
    datastore   = "flash"
    rootfs_gb   = 16
    cores       = 1
    memory_mb   = 1024
    swap_mb     = 512
    bridge      = "vmbr0"
    vlan_id     = 0
    ipv4_cidr   = "192.168.68.213/24"
    gateway     = "192.168.68.1"
    unprivileged = true
    nesting     = true
    groups      = ["docker_hosts","qBitTorrent","media_stack"]
    binds = [
      { share = "media", ct_path = "/mnt/media" }    # auto mp index
    ]
    ssh_key_files = [
      "~/.ssh/id_ed25519.pub"
    ]
  },

  {
    name        = "Arrs"
    ostype      = "ubuntu"
    ctid        = 214
    node        = "proxmox01"
    pool_id     = "default"
    datastore   = "flash"
    rootfs_gb   = 32
    cores       = 1
    memory_mb   = 1024
    swap_mb     = 1024
    bridge      = "vmbr0"
    vlan_id     = 0
    ipv4_cidr   = "192.168.68.214/24"
    gateway     = "192.168.68.1"
    unprivileged = false
    nesting     = false
    groups      = ["docker_hosts","privileged"]
    binds = [
      { share = "media", ct_path = "/mnt/media" }    # auto mp index
    ]
    ssh_key_files = [
      "~/.ssh/id_ed25519.pub"
    ]
  },

  {
    name        = "Graphs"
    ostype      = "ubuntu"
    ctid        = 215
    node        = "proxmox01"
    pool_id     = "default"
    datastore   = "flash"
    rootfs_gb   = 32
    cores       = 1
    memory_mb   = 4096
    swap_mb     = 4096
    bridge      = "vmbr0"
    vlan_id     = 0
    ipv4_cidr   = "192.168.68.215/24"
    gateway     = "192.168.68.1"
    unprivileged = true
    nesting     = true
    groups      = ["docker_hosts","graphs","media_stack"]
    binds = []
    ssh_key_files = [
      "~/.ssh/id_ed25519.pub"
    ]
  },

  {
    name        = "Codex"
    ostype      = "ubuntu"
    ctid        = 216
    node        = "proxmox01"
    pool_id     = "default"
    datastore   = "flash"
    rootfs_gb   = 32
    cores       = 1
    memory_mb   = 2048
    swap_mb     = 1024
    bridge      = "vmbr0"
    vlan_id     = 0
    ipv4_cidr   = "192.168.68.216/24"
    gateway     = "192.168.68.1"
    unprivileged = true
    nesting     = true
    groups      = ["devtools","codex"]
    binds = []
    ssh_key_files = [
      "~/.ssh/id_ed25519.pub"
    ]
  },


  {
    name        = "Homepage"
    ostype      = "ubuntu"
    ctid        = 217
    node        = "proxmox01"
    pool_id     = "default"
    datastore   = "flash"
    rootfs_gb   = 8
    cores       = 1
    memory_mb   = 2048
    swap_mb     = 1024
    bridge      = "vmbr0"
    vlan_id     = 0
    ipv4_cidr   = "192.168.68.217/24"
    gateway     = "192.168.68.1"
    unprivileged = true
    nesting     = true
    groups      = ["docker_hosts","homepage"]
    binds = []
    ssh_key_files = [
      "~/.ssh/id_ed25519.pub"
    ]
  },

  {
    name        = "Cockpit02"
    ostype      = "ubuntu"
    ctid        = 230
    node        = "proxmox01"
    pool_id     = "default"
    datastore   = "flash"
    rootfs_gb   = 16
    cores       = 1
    memory_mb   = 2048
    swap_mb     = 2048
    bridge      = "vmbr0"
    vlan_id     = 0
    ipv4_cidr   = "192.168.68.230/24"
    gateway     = "192.168.68.1"
    unprivileged = true
    nesting     = true
    groups      = ["cockpit"]   # not a docker_host
    binds = [
      { share = "media",  ct_path = "/mnt/media"  }
    ]
    ssh_key_files = [
      "~/.ssh/id_ed25519.pub"
    ]
  },

  {
    name        = "Websites"
    ostype      = "ubuntu"
    ctid        = 231
    node        = "proxmox01"
    pool_id     = "default"
    datastore   = "flash"
    rootfs_gb   = 64
    cores       = 2
    memory_mb   = 2048
    swap_mb     = 2048
    bridge      = "vmbr0"
    vlan_id     = 0
    ipv4_cidr   = "192.168.68.231/24"
    gateway     = "192.168.68.1"
    unprivileged = false
    nesting     = false
    groups      = ["websites", "docker_hosts"]   # not a docker_host
    binds = [
      { share = "data",  ct_path = "/mnt/data"  }
    ]
    ssh_key_files = [
      "~/.ssh/id_ed25519.pub"
    ]
  },

  {
    name        = "Nginx-Proxy-Manager"
    ostype      = "ubuntu"
    ctid        = 232
    node        = "proxmox01"
    pool_id     = "default"
    datastore   = "flash"
    rootfs_gb   = 8
    cores       = 1
    memory_mb   = 1024
    swap_mb     = 512
    bridge      = "vmbr0"
    vlan_id     = 0
    ipv4_cidr   = "192.168.68.232/24"
    gateway     = "192.168.68.1"
    unprivileged = false
    nesting     = false
    groups      = ["docker_hosts","privileged"]   # not a docker_host
    binds = []
    ssh_key_files = [
      "~/.ssh/id_ed25519.pub"
    ]
  },

  {
    name        = "Cloudflared"
    ostype      = "ubuntu"
    ctid        = 233
    node        = "proxmox01"
    pool_id     = "default"
    datastore   = "flash"
    rootfs_gb   = 4
    cores       = 1
    memory_mb   = 512
    swap_mb     = 512
    bridge      = "vmbr0"
    vlan_id     = 0
    ipv4_cidr   = "192.168.68.233/24"
    gateway     = "192.168.68.1"
    unprivileged = true
    nesting     = true
    groups      = ["cloudflared"]   # not a docker_host
    binds = [
      { share = "data",  ct_path = "/mnt/data"  }
    ]
    ssh_key_files = [
      "~/.ssh/id_ed25519.pub"
    ]
  },
]
