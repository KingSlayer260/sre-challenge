output "vm_ip" {
  value = split("/", var.vm_ip)[0]
}
