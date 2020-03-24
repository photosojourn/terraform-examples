data "aws_ssm_parameter" "admin_password" {
  name = "/example/grafana/admin_password"
}

resource "aws_security_group" "grafana_ecs_tasks" {
  name        = "ecs-grafana"
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

resource "aws_iam_role" "grafana-exec-role" {
  name = "grafana-ecs-exec-role"

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

resource "aws_iam_role_policy_attachment" "grafana-general" {
 role = aws_iam_role.grafana-exec-role.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  execution_role_arn       = aws_iam_role.grafana-exec-role.arn

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "grafana/grafana:latest",
    "memory": ${var.fargate_memory},
    "name": "grafana",
    "executionRoleArn": "${aws_iam_role.grafana-exec-role.arn}",
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
            "awslogs-stream-prefix": "grafana",
            "awslogs-region": "${var.region}"
      }
    },
    "environment": [
      { "name": "type",
        "value": "mysql" 
      },
      { "name": "url",
        "value": "mysql://grafana:${data.aws_ssm_parameter.rds_password.value}}@${module.grafana-rds.this_db_instance_endpoint}" 
      },
      { "name": "admin_password",
        "value": "${data.aws_ssm_parameter.admin_password.value}" 
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name            = "grafana"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.grafana.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.grafana_ecs_tasks.id}"]
    subnets         = "${module.vpc.private_subnets}"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.grafana.arn
    container_name = "grafana"
    container_port = var.app_port
  }

  depends_on = [
    aws_alb_listener.front_end,
  ]
}