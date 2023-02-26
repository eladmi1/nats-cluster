resource "aws_route53_record" "route" {
  zone_id = "Z03426271WYK1UIK7PFGW"
  name    = "route.314d.link"
  type    = "A"

  alias {
    name                   = aws_alb.nats_seed_route_lb.dns_name
    zone_id                = aws_alb.nats_seed_route_lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "client1" {
  zone_id = "Z03426271WYK1UIK7PFGW"
  name    = "client1.314d.link"
  type    = "A"

  alias {
    name                   = aws_alb.nats_server1_client_lb.dns_name
    zone_id                = aws_alb.nats_server1_client_lb.zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "client2" {
  zone_id = "Z03426271WYK1UIK7PFGW"
  name    = "client2.314d.link"
  type    = "A"

  alias {
    name                   = aws_alb.nats_server2_client_lb.dns_name
    zone_id                = aws_alb.nats_server2_client_lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "client-seed" {
  zone_id = "Z03426271WYK1UIK7PFGW"
  name    = "client-seed.314d.link"
  type    = "A"

  alias {
    name                   = aws_alb.nats_seed_client_lb.dns_name
    zone_id                = aws_alb.nats_seed_client_lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "monitor" {
  zone_id = "Z03426271WYK1UIK7PFGW"
  name    = "monitor.314d.link"
  type    = "A"

  alias {
    name                   = aws_alb.nats_seed_monitor_lb.dns_name
    zone_id                = aws_alb.nats_seed_monitor_lb.zone_id
    evaluate_target_health = true
  }
}