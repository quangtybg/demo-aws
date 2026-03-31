data "aws_route53_zone" "zone" {
  count = var.domain != "" ? 1 : 0
  name  = var.domain
}

resource "aws_route53_record" "alb" {
  count   = var.domain != "" ? 1 : 0
  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = "www"
  type    = "A"
  alias {
    name                   = var.alb_arn
    zone_id                = data.aws_route53_zone.zone[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "nlb" {
  count   = var.domain != "" ? 1 : 0
  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = "nlb"
  type    = "A"
  ttl     = 300
  records = [var.nlb_dns]
}
