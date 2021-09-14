# Create a pool for volumes to use
resource "libvirt_pool" "cluster" {
  name = "vms-cluster"
  type = "dir"
  path = var.vm_pool_path
}

# Use a base image for the VMs
resource "libvirt_volume" "base_image" {
  name   = var.base_image_name
  pool   = libvirt_pool.cluster.name
  source = var.base_image_uri
}

resource "libvirt_volume" "vm_disks" {
  count          = var.vm_count
  name           = "vm-${count.index}-vol"
  pool           = libvirt_pool.cluster.name
  base_volume_id = libvirt_volume.base_image.id
}