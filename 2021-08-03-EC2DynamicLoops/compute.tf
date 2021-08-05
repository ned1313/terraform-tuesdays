locals {
  csv_data = csvdecode(file("values.csv"))

  data_map = { for k in local.csv_data : k.Group => k }

  disk1_list = [
    for k, v in local.data_map : {
      Group       = k
      disksize    = v.Disk1Size
      diskperf    = v.Disk1Perf
      device_name = "/dev/sda1"
    }
    if v.Disk1Size != "0"
  ]

  disk2_list = [
    for k, v in local.data_map : {
      Group       = k
      disksize    = v.Disk2Size
      diskperf    = v.Disk2Perf
      device_name = "/dev/sda2"
    }
    if v.Disk2Size != "0"
  ]

  disk3_list = [
    for k, v in local.data_map : {
      Group       = k
      disksize    = v.Disk3Size
      diskperf    = v.Disk3Perf
      device_name = "/dev/sda3"
    }
    if v.Disk3Size != "0"
  ]

  all_disks = concat(local.disk1_list, local.disk2_list, local.disk3_list)

}

resource "aws_launch_template" "taco-machines" {
  for_each = local.data_map

  name_prefix = each.key

  image_id      = each.value.ImageId
  instance_type = each.value.InstanceType

  dynamic "block_device_mappings" {
    for_each = [for disks in local.all_disks : disks if each.key == disks.Group]
    content {
      device_name = block_device_mappings.value["device_name"]

      ebs {
        volume_size = block_device_mappings.value["disksize"]
        volume_type = block_device_mappings.value["diskperf"]
      }
    }
  }

}