data "template_file" "vault_userdata" {
  template = "${file("${path.cwd}/user-data/vault-userdata.tpl")}"
  vars = {
    key_id = aws_kms_key.vault_key.key_id
  }
}

module "vault-asg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-autoscaling.git?ref=master"

  name = "vault"

  # Launch configuration
  lc_name = "vault-lc"

  image_id             = "ami-08fc8d0185bfae26e"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.vault.id,aws_security_group.consul.id]
  iam_instance_profile = aws_iam_instance_profile.vault_instance_profile.arn
  user_data            = data.template_file.vault_userdata.rendered
  key_name             = "russ-aws-sandbox"
  target_group_arns    = [aws_alb_target_group.vault.arn]

  root_block_device = [
    {
      volume_size = "20"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "vault-asg"
  vpc_zone_identifier       = module.vpc.private_subnets
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 3
  desired_capacity          = 3
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Owner"
      value               = "Russ W"
      propagate_at_launch = true
    },
    {
      key                 = "Consul"
      value               = "true"
      propagate_at_launch = true
    }
  ]
}

resource "aws_security_group" "vault" {
  name        = "vault-sg"
  description = "allow inbound access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = "8200"
    to_port     = "8200"
    security_groups = [aws_security_group.vault_lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

