resource "aws_route53_record" "route" {
  zone_id = "Z03426271WYK1UIK7PFGW"
  name    = "route.314d.link"
  type    = "A"

  alias {
    name                   = aws_alb.nats_seed_route_load_balancer.dns_name
    zone_id                = aws_alb.nats_seed_route_load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "client" {
  zone_id = "Z03426271WYK1UIK7PFGW"
  name    = "client.314d.link"
  type    = "A"

  alias {
    name                   = aws_alb.nats_server_client_load_balancer.dns_name
    zone_id                = aws_alb.nats_server_client_load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "monitor" {
  zone_id = "Z03426271WYK1UIK7PFGW"
  name    = "monitor.314d.link"
  type    = "A"

  alias {
    name                   = aws_alb.nats_seed_monitor_load_balancer.dns_name
    zone_id                = aws_alb.nats_seed_monitor_load_balancer.zone_id
    evaluate_target_health = true
  }
}