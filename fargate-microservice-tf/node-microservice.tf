
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-node-microservice"
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

resource "aws_iam_role" "node-microservice-exec-role" {
  name = "node-microservice-ecs-exec-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "node-microservice-general" {
 role = aws_iam_role.go-microservice-exec-role.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "node-microservice" {
  family                   = "node-microservice"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  execution_role_arn       = aws_iam_role.node-microservice-exec-role.arn

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.node_app_image}",
    "memory": ${var.fargate_memory},
    "name": "node-microservice",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "microservices",
        "awslogs-stream-prefix": "node-microservice",
        "awslogs-region": "${var.region}"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "node-microservice" {
  name            = "node-microservice"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.node-microservice.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = "${module.vpc.private_subnets}"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.node-microservice.arn
    container_name = "node-microservice"
    container_port = var.app_port
  }

  depends_on = [
    aws_alb_listener.front_end,
  ]
}