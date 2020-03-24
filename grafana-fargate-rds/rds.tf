data "aws_ssm_parameter" "rds_password" {
    name = "/example/grafana/rds_pwd"
}

resource "aws_security_group" "grafana_rds" {
  name        = "grafana-rds"
  description = "allow inbound access from the Grafana fargate"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = ["${aws_security_group.grafana_ecs_tasks.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


module "grafana-rds" {
    source  = "terraform-aws-modules/rds/aws"
    version = "~> 2.0"

    identifier = "grafanadb"

    engine = "mysql"
    family = "mysql5.7"
    major_engine_version = "5.7"
    engine_version    = "5.7.19"
    instance_class = "db.t2.large"
    allocated_storage = 10

    name = "grafanadb"
    username = "grafana"
    password = "${data.aws_ssm_parameter.rds_password.value}"
    port = "3306"

    maintenance_window = "Mon:00:00-Mon:03:00"
    backup_window      = "03:00-06:00"

    vpc_security_group_ids = ["${aws_security_group.grafana_rds.id}"]
    subnet_ids = module.vpc.private_subnets

    final_snapshot_identifier = "grafanadb"
}