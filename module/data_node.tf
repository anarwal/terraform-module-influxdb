resource "aws_instance" "data_node" {
  ami             = data.aws_ami.influxdb_ami.id
  instance_type   = var.data_instance_type
  name            = var.name
  subnet_id       = data.aws_subnet.selected.id
  security_groups = aws_security_group.data_node.id
  user_data       = data.template_file.init.rendered
  tags            = var.tags
  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = "25"
      delete_on_termination = true
    },
  ]
}

resource "aws_ebs_volume" "data" {
  size              = var.data_disk_size
  encrypted         = true
  type              = "io1"
  iops              = var.data_disk_iops
  snapshot_id       = var.data_disk_snaphot
  availability_zone = data.aws_subnet.selected.availability_zone
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-data"
    },
    {
      "Role" = "${replace(var.name, "-", "_")}_data"
    },
    {
      "Type" = "data"
    },
    {
      "Snapshot" = "influxdb"
    },
  )
}

resource "aws_volume_attachment" "data_attachment" {
  device_name  = var.data_disk_device_name
  volume_id    = aws_ebs_volume.data.id
  instance_id  = aws_instance.data_node.id
  force_detach = var.force_detach
}

resource "aws_ebs_volume" "wal" {
  size              = var.wal_disk_size
  encrypted         = true
  type              = "io1"
  iops              = var.wal_disk_iops
  snapshot_id       = var.wal_disk_snaphot
  availability_zone = data.aws_subnet.selected.availability_zone
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-wal"
    },
    {
      "Role" = "${replace(var.name, "-", "_")}_wal"
    },
    {
      "Type" = "wal-data"
    },
    {
      "Snapshot" = "influxdb"
    },
  )
}

resource "aws_volume_attachment" "wal_attachment" {
  device_name  = var.wal_disk_device_name
  volume_id    = aws_ebs_volume.wal.id
  instance_id  = aws_instance.data_node.id
  force_detach = var.force_detach
}

resource "aws_ebs_volume" "meta" {
  size              = var.meta_disk_size
  encrypted         = true
  type              = "gp2"
  snapshot_id       = var.meta_disk_snaphot
  availability_zone = data.aws_subnet.selected.availability_zone
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-meta"
    },
    {
      "Role" = "${replace(var.name, "-", "_")}_meta"
    },
    {
      "Type" = "meta-data"
    },
    {
      "Snapshot" = "influxdb"
    },
  )
}

resource "aws_volume_attachment" "meta_attachment" {
  device_name  = var.meta_disk_device_name
  volume_id    = aws_ebs_volume.meta.id
  instance_id  = aws_instance.data_node.id
  force_detach = var.force_detach
}

