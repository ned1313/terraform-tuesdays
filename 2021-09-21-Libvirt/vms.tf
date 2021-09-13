resource "libvirt_domain" "vms" {
  count      = var.vm_count
  name       = "${var.vm_name_prefix}-${count.index}"
  memory     = var.vm_memory
  vcpu       = var.vm_vcpu
  autostart  = var.autostart
  qemu_agent = true

  network_interface {
    bridge         = var.bridge
    wait_for_lease = true
    hostname       = "${var.vm_name_prefix}-${count.index}"
  }

  disk {
    volume_id = libvirt_volume.vm_disks[count.index].id
  }

}