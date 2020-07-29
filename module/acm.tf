# ---------------------------------------------------------------------------------------------------------------------
# CREATE ACM CERTIFICATE FOR INFLUXDB LOAD BALANCER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_acm_certificate" "influxdb_monitoring_application_cert" {
  domain_name       = var.dns_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "influxdb_monitoring_application_route_53_cert_validation" {
  name    = aws_acm_certificate.influxdb_monitoring_application_cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.influxdb_monitoring_application_cert.domain_validation_options[0].resource_record_type
  zone_id = var.zone_id
  records = [aws_acm_certificate.influxdb_monitoring_application_cert.domain_validation_options[0].resource_record_value]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "influxdb_monitoring_application_cert_validation" {
  certificate_arn         = aws_acm_certificate.influxdb_monitoring_application_cert.arn
  validation_record_fqdns = [aws_route53_record.influxdb_monitoring_application_route_53_cert_validation.fqdn]
}
