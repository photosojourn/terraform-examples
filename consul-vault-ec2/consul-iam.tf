data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid = "AccessAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "consul_autojoin" {
  statement {
    sid = "ConsulAutoJoin"

    actions = [
      "ec2:DescribeInstances"
    ]

    resources = [
      "*"
    ]
  }

}

resource "aws_iam_policy" "consul_autojoin" {
  name   = "consul_autojoin"
  path   = "/"
  policy = data.aws_iam_policy_document.consul_autojoin.json
}

resource "aws_iam_role" "consul_instance_role" {
  name = "consul-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_instance_profile" "consul_instance_profile" {
  name = "consul-profile"

  role = aws_iam_role.consul_instance_role.name
}

resource "aws_iam_role_policy_attachment" "consul-ssm" {
  role       = aws_iam_role.consul_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

resource "aws_iam_role_policy_attachment" "consul-autojoin" {
  role       = aws_iam_role.consul_instance_role.name
  policy_arn = aws_iam_policy.consul_autojoin.arn

}