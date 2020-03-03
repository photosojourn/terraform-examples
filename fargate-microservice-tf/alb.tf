# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {
  name        = "ecs-alb"
  description = "controls access to the ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "main" {
  name            = "ecs-fargate-example"
  subnets         = module.vpc.public_subnets
  security_groups = ["${aws_security_group.lb.id}"]
}

resource "aws_alb_target_group" "go-microservice" {
  name        = "ecs-go-microservice"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_alb_target_group" "node-microservice" {
  name        = "ecs-node-microservice"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

# Set a fixed response for the root i.e 404
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page Not Found"
      status_code = 400
    }
  }
}

resource "aws_alb_listener_rule" "go-microservice" {
  listener_arn = aws_alb_listener.front_end.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.go-microservice.arn
  }

  condition {
    path_pattern {
      values = ["/go"]
    }
  }
}

resource "aws_alb_listener_rule" "node-microservice" {
  listener_arn = aws_alb_listener.front_end.arn
  priority = 101

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.node-microservice.arn
  }

  condition {
    path_pattern {
      values = ["/node"]
    }
  }
}

