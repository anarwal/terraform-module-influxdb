output "fqdn" {
  value = module.influxdb.influxdb_lb_fqdn
}

output "influxdb_ip" {
  value = module.influxdb.influxdb_ip
}
