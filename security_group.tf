resource "aws_security_group" "nats_route_security_group" {
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
resource "aws_security_group" "nats_client_security_group" {
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

resource "aws_security_group" "nats_monitor_security_group" {
  ingress {
    from_port   = "${var.http_monitoring_port}"
    to_port     = "${var.http_monitoring_port}"
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
