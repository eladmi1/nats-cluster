resource "aws_ecs_task_definition" "nats_seed_task" {
  family                   = "nats_seed_task"
  container_definitions    = jsonencode([
      {
        "command": ["--cluster_name", "NATS", "--cluster", "nats://0.0.0.0:6222", "--http_port", "8222"],
         "essential": true,
         "image": "nats:latest",
         "name": "nats_seed",
         "portMappings": [
            {
               "containerPort": 8222,
               "hostPort": 8222
            },
            {
               "containerPort": 6222,
               "hostPort": 6222
            },
            {
               "containerPort": 4222,
               "hostPort": 4222
            }
         ]
      }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}


resource "aws_alb" "nats_seed_route_lb" {
  name               = "nats-seed-route-lb"
  load_balancer_type = "network"
  subnets = [
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
}

resource "aws_alb" "nats_seed_client_lb" {
  name               = "nats-seed-client-lb"
  load_balancer_type = "network"
  subnets = [
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
}

resource "aws_alb" "nats_seed_monitor_lb" {
  name               = "nats-seed-monitor-lb"
  load_balancer_type = "application"
  subnets = [
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
  security_groups = ["${aws_security_group.nats_monitor_security_group.id}"]
}

resource "aws_lb_target_group" "nats_seed_route_target_group" {
  name        = "nats-seed-route-target-group"
  port        = "${var.route_port}"
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}" 
}

resource "aws_lb_target_group" "nats_seed_client_target_group" {
  name        = "nats-seed-client-target-group"
  port        = "${var.client_port}"
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}" 
}

resource "aws_lb_target_group" "nats_seed_monitor_target_group" {
  name        = "nats-seed-monitor-target-group"
  port        = "${var.http_monitoring_port}"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}"
    health_check {
    matcher = "200"
    path = "/"
  }
}

resource "aws_lb_listener" "nats_seed_route_listener" {
  load_balancer_arn = "${aws_alb.nats_seed_route_lb.arn}" 
  port              = "${var.route_port}"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nats_seed_route_target_group.arn}" 
  }
}

resource "aws_lb_listener" "nats_seed_client_listener" {
  load_balancer_arn = "${aws_alb.nats_seed_client_lb.arn}" 
  port              = "${var.client_port}"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nats_seed_client_target_group.arn}" 
  }
}

resource "aws_lb_listener" "nats_seed_monitor_listener" {
  load_balancer_arn = "${aws_alb.nats_seed_monitor_lb.arn}" 
  port              = "${var.http_monitoring_port}"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nats_seed_monitor_target_group.arn}" 
  }
}
