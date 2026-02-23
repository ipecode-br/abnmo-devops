resource "aws_ses_domain_identity" "this" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "this" {
  count  = var.enable_dkim ? 1 : 0
  domain = var.domain
}

resource "aws_ses_email_identity" "emails" {
  for_each = toset(var.email_identities)
  email    = each.value
}

# Route53 Records for SES Verification and DKIM
resource "aws_route53_record" "ses_verification" {
  count   = var.manage_dns ? 1 : 0
  zone_id = var.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = 600
  records = [aws_ses_domain_identity.this.verification_token]
}

resource "aws_route53_record" "dkim" {
  count   = var.manage_dns && var.enable_dkim ? 3 : 0
  zone_id = var.zone_id
  name    = "${aws_ses_domain_dkim.this[0].dkim_tokens[count.index]}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = 600
  records = [
    "${aws_ses_domain_dkim.this[0].dkim_tokens[count.index]}.dkim.amazonses.com"
  ]
}