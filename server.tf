resource "aws_ecs_task_definition" "nats_server_task" {
  family                   = "nats_server_task"
  container_definitions    = jsonencode([
      {
         "command": ["--cluster_name", "NATS", "--cluster", "nats://0.0.0.0:6222", "--routes=nats://ruser:T0pS3cr3t@route.314d.link:6222"],
         "essential": true,
         "image": "nats:latest",
         "name": "nats_server",
         "portMappings": [
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

resource "aws_security_group" "nats_server_route_security_group" {
  ingress {
    from_port   = "${var.route_port}"
    to_port     = "${var.route_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "nats_server_client_security_group" {
  ingress {
    from_port   = "${var.client_port}"
    to_port     = "${var.client_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_alb" "nats_server_route_load_balancer" {
  name               = "nats-server-route-load-balancer"
  load_balancer_type = "network"
  subnets = [
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
}

resource "aws_alb" "nats_server_client_load_balancer" {
  name               = "nats-server-client-load-balancer"
  load_balancer_type = "network"
  subnets = [
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
}

resource "aws_lb_target_group" "nats_server_route_target_group" {
  name        = "nats-server-route-target-group"
  port        = "${var.route_port}"
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}" 
}

resource "aws_lb_target_group" "nats_server_client_target_group" {
  name        = "nats-server-client-target-group"
  port        = "${var.client_port}"
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}" 
}

resource "aws_lb_listener" "nats_server_route_listener" {
  load_balancer_arn = "${aws_alb.nats_server_route_load_balancer.arn}" 
  port              = "${var.route_port}"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nats_server_route_target_group.arn}" 
  }
}

resource "aws_lb_listener" "nats_server_client_listener" {
  load_balancer_arn = "${aws_alb.nats_server_client_load_balancer.arn}" 
  port              = "${var.client_port}"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nats_server_client_target_group.arn}" 
  }
}
