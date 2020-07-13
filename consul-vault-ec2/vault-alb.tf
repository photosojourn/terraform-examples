# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "vault_lb" {
  name        = "vault-alb"
  description = "controls access to the ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 8200
    to_port     = 8200
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8500
    to_port     = 8500
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
  name            = "vault"
  subnets         = module.vpc.public_subnets
  security_groups = ["${aws_security_group.vault_lb.id}"]
}

resource "aws_alb_target_group" "vault" {
  name        = "vault"
  port        = 8200
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path = "/v1/sys/health"
    matcher = "200,429"
  }
}

resource "aws_alb_target_group" "consul" {
  name        = "consul-ui"
  port        = 8500
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path = "/ui/"
    matcher = "200"
  }
}

resource "aws_alb_listener" "vault_front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = "8200"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.vault.arn
  }
}

resource "aws_alb_listener" "consul_front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = "8500"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.consul.arn
  }
}
