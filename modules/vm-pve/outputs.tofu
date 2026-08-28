# modules/vm-pve/outputs.tofu

output "vm_id" {
  description = "VMID of the provisioned VM."
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "Name of the provisioned VM."
  value       = proxmox_virtual_environment_vm.this.name
}

output "ipv4_addresses" {
  description = "Addresses reported by the guest agent, excluding loopback."
  value = [
    for addr in flatten(proxmox_virtual_environment_vm.this.ipv4_addresses) :
    addr if addr != "127.0.0.1"
  ]
}

output "ansible_roles" {
  description = "Ansible roles the spec declares for this VM (layer 2)."
  value       = var.spec.ansible_roles
}

# Passed through to the ansible inventory, which is what applies them now that
# there is no cloud-init snippet.
output "packages" {
  description = "apt packages the spec declares for this VM (layer 2)."
  value       = var.spec.packages
}

output "archive_snapshot" {
  description = "snapshot.ubuntu.com ID the spec pins apt to, or null (layer 2)."
  value       = var.spec.archive_snapshot
}

output "ssh_command" {
  description = "Ready-to-run SSH command for the cloud-init user."
  value = format(
    "ssh %s@%s",
    var.ci_user,
    try(
      [
        for addr in flatten(proxmox_virtual_environment_vm.this.ipv4_addresses) :
        addr if addr != "127.0.0.1"
      ][0],
      "<pending>",
    ),
  )
}
