/*data "aws_ssm_parameter" "aws_ami" {
    name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}*/


data "template_file" "consul_userdata" {
  template = "${file("${path.cwd}/user-data/consul-userdata.tpl")}"
}

module "asg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-autoscaling.git?ref=master"

  name = "consul"

  # Launch configuration
  lc_name = "consul-lc"

  image_id             = "ami-08fc8d0185bfae26e"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.consul.id]
  iam_instance_profile = aws_iam_instance_profile.consul_instance_profile.arn
  user_data            = data.template_file.consul_userdata.template
  key_name             = "russ-aws-sandbox"

  root_block_device = [
    {
      volume_size = "20"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "consul-asg"
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

resource "aws_security_group" "consul" {
  name        = "consul-sg"
  description = "allow inbound access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Consul DNS"
    protocol    = "tcp"
    from_port   = "8600"
    to_port     = "8600"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Consul HTTP"
    protocol    = "tcp"
    from_port   = "8500"
    to_port     = "8500"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Consul LAN Serf"
    protocol    = "tcp"
    from_port   = "8301"
    to_port     = "8301"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Consul WAN Serf"
    protocol    = "tcp"
    from_port   = "8302"
    to_port     = "8302"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Consul Server RPC"
    protocol    = "tcp"
    from_port   = "8300"
    to_port     = "8300"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

