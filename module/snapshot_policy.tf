data "aws_caller_identity" "current" {
}

resource "aws_dlm_lifecycle_policy" "data" {
  description        = "Influxdb Data Volume DLM lifecycle policy"
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/StackSetDLMRole"
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "${var.name}-data Influxdb Daily Snapshots"

      create_rule {
        interval      = var.snapshot_interval
        interval_unit = "HOURS"
        times         = [var.snapshot_start_time]
      }

      retain_rule {
        count = var.retain_rule
      }

      tags_to_add = {
        Snapshot_type = "${var.name}-data-influxdb-daily-snapshot"
      }

      copy_tags = true
    }

    target_tags = {
      Snapshot = "influxdb"
    }
  }
}

