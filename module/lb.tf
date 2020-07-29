# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CLASSIC LOAD BALANCER FOR INFLUXDB
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_elb" "influxdb_elb" {
  name            = "${var.name}-elb"
  idle_timeout    = var.influxdb_lb_ideal_timeout
  internal        = true
  security_groups = [aws_security_group.lb.id]
  subnets         = var.subnet_id
  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
    {
      "Role" = "influx"
    },
  )
  connection_draining         = true
  connection_draining_timeout = 400

  access_logs {
    bucket        = aws_s3_bucket.lb_s3_bucket.id
    bucket_prefix = var.name
    enabled       = true
  }

  listener {
    instance_port      = 8086
    instance_protocol  = "HTTPS"
    lb_port            = 443
    lb_protocol        = "HTTPS"
    ssl_certificate_id = aws_acm_certificate.influxdb_monitoring_application_cert.arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 15
    target              = "HTTPS:8086/ping?verbose=true"
    interval            = 30
  }
}

resource "aws_elb_attachment" "influxdb_elb_attachment" {
  elb      = aws_elb.influxdb_elb.id
  instance = aws_instance.data_node.id
}

