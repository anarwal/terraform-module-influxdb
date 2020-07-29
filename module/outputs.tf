output "influxdb_id" {
  description = "A data node instance id"
  value       = [aws_instance.data_node.id]
}

output "influxdb_ip" {
  description = "Private IP of influxdb"
  value       = [aws_instance.data_node.private_ip]
}

output "influxdb_lb_fqdn" {
  description = "fqdn of influxdb"
  value       = element(concat(aws_route53_record.influxdb_monitoring_application_route_53_cert_validation.*.fqdn, [""]), 0)
}
