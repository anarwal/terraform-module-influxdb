data "aws_subnet" "selected" {
  id = element(var.subnet_id, 0)
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_elb_service_account" "main" {
}

data "aws_ami" "influxdb_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["packer_influxdb"]
  }
  filter {
    name   = "tag:version"
    values = ["release"]
  }

  filter {
    name   = "tag:release"
    values = [var.ami_release_tag]
  }
}

data "template_file" "init" {
  template = file("${path.module}/files/init.sh")

  vars = {
    meta_data_disk = var.meta_disk_device_name
    data_disk      = var.data_disk_device_name
    wal_data_disk  = var.wal_disk_device_name
    read_buffer    = var.buffer_size
    data_base      = var.data_base
    batch_timeout  = var.batch_timeout
    batch_pending  = var.batch_pending
    batch_size     = var.batch_size
    duration       = var.duration
    debug_duration = var.debug_duration
  }
}

