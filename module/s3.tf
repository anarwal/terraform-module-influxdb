resource "aws_s3_bucket" "lb_s3_bucket" {
  bucket             = var.s3_bucket_name
  acl                = "private"
  force_destroy      = var.force_destroy_s3
  policy             = local.lb_s3_bucket_policy
  tags               = var.tags
}

locals {
  ## Created policy as per AWS docs: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
  lb_s3_bucket_policy = <<POLICY
{
  "Id": "LbS3BucketPolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1561995541176",
      "Action": "s3:PutObject",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.lb_s3_bucket.id}/${var.name}/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.id}"
        ]
      }
    },
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.lb_s3_bucket.id}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY

}

