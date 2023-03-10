resource "aws_ecs_task_definition" "nats_server2_task" {
  family                   = "nats_server2_task"
  container_definitions    = jsonencode([
      {
         "command": ["--cluster_name", "NATS", "--cluster", "nats://0.0.0.0:6222", "--routes=nats://ruser:T0pS3cr3t@route.314d.link:6222"],
         "essential": true,
         "image": "nats:latest",
         "name": "nats_server2",
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

resource "aws_alb" "nats_server2_client_lb" {
  name               = "nats-server2-client-lb"
  load_balancer_type = "network"
  subnets = [
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
}

resource "aws_lb_target_group" "nats_server2_client_target_group" {
  name        = "nats-server2-client-target-group"
  port        = "${var.client_port}"
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}" 
}

resource "aws_lb_listener" "nats_server2_client_listener" {
  load_balancer_arn = "${aws_alb.nats_server2_client_lb.arn}" 
  port              = "${var.client_port}"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nats_server2_client_target_group.arn}" 
  }
}
