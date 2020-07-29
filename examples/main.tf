provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "influxdb" {
  source           = "../module"
  dns_name         = var.dns_name
  vpc_id           = var.vpc_id
  name             = "influxdb"
  vpc_name         = var.vpc_name
  vpc_cidr         = var.vpc_cidr
  zone_id          = var.zone_id
  subnet_id        = var.subnet_id
  ami_release_tag  = "v0.0.1"
  env_name         = var.env_name
  force_destroy_s3 = "true"
  force_detach     = "false"
  tags             = var.tags
}
