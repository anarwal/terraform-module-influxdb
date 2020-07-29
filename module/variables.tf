variable "name" {
  description = "The prefix that will be applied to resources managed by this module"
  default     = "influx"
}

variable "email_address" {
  description = "The Email address you want to send notifications for the EC2 instance."
  default     = ""
}

variable "slack_webhook_url" {
  description = "The slack_webhook_url address you want to send notifications for the EC2 instance."
  default     = ""
}

variable "env_name" {
  description = "environment that the instance is being created in ex nwm-poc-26"
  type        = string
}

variable "vpc_name" {
  description = "The name of the vpc that the resource is being created in"
}

variable "vpc_id" {
  description = "Id of the VPC influxdb will be provisioned in."
}

variable "vpc_cidr" {
  description = "CIDR Range of the VPC influxdb will be provisioned in."
}

variable "ami_release_tag" {
  description = "The tag of the packer image to filter for. Example 1.0.0"
}

variable "tags" {
  description = "Tags to be applied to all resources managed by this module"
  type        = map(string)
}

variable "subnet_id" {
  description = "The subnet ID for server"
  type        = list(string)
}

variable "data_instance_type" {
  description = "The AWS Instance type for the Data Node. For example, m5.large"
  default     = "r5.xlarge"
}

variable "zone_id" {
  description = "The private DNS zone to create records for hosts"
}

variable "dns_name" {
  description = "The name of the record for Route53"
}

variable "enable_lb_route_53_entry" {
  description = "Do you wish to create a route53 entry for dns or not"
  default     = 1
}

variable "data_disk_size" {
  description = "The size of the data disks to provision"
  default     = 300
}

variable "data_disk_iops" {
  description = "The number of IOPs for the io1 type volume"
  default     = 1000
}

variable "wal_disk_size" {
  description = "The size of the wal disks to provision"
  default     = 100
}

variable "wal_disk_iops" {
  description = "The number of IOPs for the io1 type volume"
  default     = 3000
}

variable "meta_disk_size" {
  description = "The size of the wal disks to provision"
  default     = 100
}

variable "data_disk_device_name" {
  description = "The name of the data device"
  default     = "/dev/sdf"
}

variable "data_disk_snaphot" {
  description = "The name of the meta device"
  default     = ""
}

variable "wal_disk_device_name" {
  description = "The name of the wal device"
  default     = "/dev/sdg"
}

variable "wal_disk_snaphot" {
  description = "The name of the meta device"
  default     = ""
}

variable "meta_disk_device_name" {
  description = "The name of the meta device"
  default     = "/dev/sdh"
}

variable "meta_disk_snaphot" {
  description = "The name of the meta device"
  default     = ""
}

variable "snapshot_interval" {
  description = "How often this lifecycle policy should be evaluated. 2,3,4,6,8,12 or 24 are valid values. Default 24"
  default     = "24"
}

variable "snapshot_start_time" {
  description = "A list of times in 24 hour clock format that sets when the lifecycle policy should be evaluated."
  default     = "00:00"
}

variable "retain_rule" {
  description = "How many snapshots to keep. Must be an integer between 1 and 1000."
  default     = "3"
}

variable "influxdb_lb_ideal_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
  default     = 60
}

variable "force_detach" {
  description = "Set to true if you want to force the volume to detach. Useful if previous attempts failed, but use this option only as a last resort, as this can result in data loss"
  type        = string
  default     = "false"
}

variable "force_destroy_s3" {
  description = "Allow terraform to force destroy the S3 bucket used for LB access logs "
  type        = string
  default     = "false"
}

variable "buffer_size" {
  description = "The OS and UDP read-buffers. default is 200MB"
  type        = string
  default     = "209715200"
}

variable "data_base" {
  description = "Name of database to create in Influxdb"
  type        = string
  default     = "influxdb"
}

variable "batch_timeout" {
  description = "UDP Batch timeout. Default 1s"
  type        = string
  default     = "1s"
}

variable "batch_pending" {
  description = "UDP Batch Pending. Default is 5"
  type        = string
  default     = "5"
}

variable "batch_size" {
  description = "UDP Batch Size. Default is 1000"
  type        = string
  default     = "1000"
}

variable "duration" {
  description = "Amount of time to keep the data in the database. Can be in Hours or Days, ie 48h or 90d respectively"
  type        = string
  default     = "90d"
}

variable "debug_duration" {
  description = "Amount of time to keep the data in the debug database. Can be in Hours or Days, ie 48h or 90d respectively"
  type        = string
  default     = "48h"
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "data_node_cidrs" {
  description = "Cidr block for data node access"
  type        = list(string)
}

variable "https_cidr_block" {
  description = "HTTPS input cidr block for Load balancer access"
  type        = list(string)
}
