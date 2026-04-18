output "name" { value = var.name }
output "ipv4" { value = var.ipv4_cidr != "dhcp" ? split("/", var.ipv4_cidr)[0] : null }
output "groups" { value = var.groups }
output "ctid"  { value = var.ctid }
output "node"  { value = var.node }

output "binds" {
  value = var.binds
}
