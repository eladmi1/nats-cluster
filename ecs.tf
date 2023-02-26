resource "aws_ecs_service" "nats_seed_service" {
  name            = "nats-seed-service"
  cluster         = aws_ecs_cluster.nats_cluster.id
  task_definition = aws_ecs_task_definition.nats_seed_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  
  load_balancer {
    target_group_arn = "${aws_lb_target_group.nats_seed_route_target_group.arn}" 
    container_name   = "nats_seed"
    container_port   = "${var.route_port}"
  }
  load_balancer {
    target_group_arn = "${aws_lb_target_group.nats_seed_client_target_group.arn}" 
    container_name   = "nats_seed"
    container_port   = "${var.client_port}"
  }
  
 load_balancer {
    target_group_arn = "${aws_lb_target_group.nats_seed_monitor_target_group.arn}" 
    container_name   = "nats_seed"
    container_port   = "${var.http_monitoring_port}"
  }
  
  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    security_groups  = ["${aws_security_group.nats_route_security_group.id}","${aws_security_group.nats_monitor_security_group.id}","${aws_security_group.nats_client_security_group.id}"]
    assign_public_ip = true
  }
}
resource "aws_ecs_service" "nats_server1_service" {
  name            = "nats-server1-service"
  cluster         = aws_ecs_cluster.nats_cluster.id
  task_definition = aws_ecs_task_definition.nats_server1_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  depends_on = [
    aws_alb.nats_seed_route_lb
  ]
  
  load_balancer {
    target_group_arn = "${aws_lb_target_group.nats_server1_client_target_group.arn}" 
    container_name   = "nats_server1"
    container_port   = "${var.client_port}"
  }
  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    security_groups  = ["${aws_security_group.nats_route_security_group.id}","${aws_security_group.nats_client_security_group.id}"]
    assign_public_ip = true
  }
}


resource "aws_ecs_service" "nats_server2_service" {
  name            = "nats-server2-service"
  cluster         = aws_ecs_cluster.nats_cluster.id
  task_definition = aws_ecs_task_definition.nats_server2_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  depends_on = [
    aws_alb.nats_seed_route_lb
  ]

  load_balancer {
    target_group_arn = "${aws_lb_target_group.nats_server2_client_target_group.arn}" 
    container_name   = "nats_server2"
    container_port   = "${var.client_port}"
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    security_groups  = ["${aws_security_group.nats_route_security_group.id}","${aws_security_group.nats_client_security_group.id}"]
    assign_public_ip = true
  }
}
