# Wildcard ACM Certificate for all API subdomains
resource "aws_acm_certificate" "wildcard_api" {
  domain_name       = "*.${var.api_domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.project_name}-wildcard-api-cert"
    Environment = "shared"
    Description = "Wildcard certificate for all API subdomains"
  }
}

# Certificate validation (controlled by dns_validation_complete variable)
resource "aws_acm_certificate_validation" "wildcard_api" {
  count = var.dns_validation_complete ? 1 : 0

  certificate_arn = aws_acm_certificate.wildcard_api.arn

  timeouts {
    create = "10m"
  }
}
