resource "aws_security_group" "data_node" {
  description = "Security group for influx data node ingress"
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
    {
      "Role" = "influx"
    },
  )

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = [var.data_node_cidrs]
    description = "SSH ingress"
  }

  # ingress traffic from load balancer
  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 8086
    security_groups = [aws_security_group.lb.id]
  }

  # default to allow all outgoing traffic
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL TRAFFIC THAT CAN GO IN AND OUT OF INFLUXDB APPLICATION LOAD BALANCER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "lb" {
  description = "Security group to allow all inbound web traffic to Load balancer"
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
    {
      "Role" = "influx"
    },
  )

  # HTTPS Ingress
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "https access from provided cidr blocks"
    cidr_blocks = [var.https_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "cidr_thing" {
  value = var.vpc_cidr
}
