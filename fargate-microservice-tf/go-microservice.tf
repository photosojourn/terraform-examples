resource "aws_security_group" "go_ecs_tasks" {
  name        = "ecs-go-microservice"
  description = "allow inbound access from the ALB only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = ["${aws_security_group.lb.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_task_definition" "go-microservice" {
  family                   = "go-microservice"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.go_app_image}",
    "memory": ${var.fargate_memory},
    "name": "go-microservice",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name            = "go-microservice"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.go-microservice.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.go_ecs_tasks.id}"]
    subnets         = "${module.vpc.private_subnets}"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.go-microservice.arn
    container_name = "go-microservice"
    container_port = var.app_port
  }

  depends_on = [
    aws_alb_listener.front_end,
  ]
}