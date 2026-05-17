# ==================================================
# Route53 - Hosted Zone (existing)
# ==================================================
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# ==================================================
# Route53 - CloudFront Alias Record
# ==================================================
resource "aws_route53_record" "cloudfront" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
