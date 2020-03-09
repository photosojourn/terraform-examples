resource "aws_iam_role" "russ-codebuild-go-microservice" {
  name = "russ-codebuild-go-microservice"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "russ-codebuild-go-microservice" {
  role = "${aws_iam_role.russ-codebuild-go-microservice.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:DescribeImages"
      ],
      "Resource": [
        "${aws_ecr_repository.russ-go-microservice.arn}"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.russ_codepipeline_bucket_go_microservice.arn}",
        "${aws_s3_bucket.russ_codepipeline_bucket_go_microservice.arn}/*"
      ]
    },
    {
        "Effect": "Allow",
        "Action": "ecr:GetAuthorizationToken",
        "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "eks:*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "russ-go-microservice" {
  name         = "russ-go-microservice"
  description  = "Build for Golang based Microservice"
  service_role = "${aws_iam_role.russ-codebuild-go-microservice.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "eu-west-1"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }

  }

  source {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "russ-codebuild"
      stream_name = "go-microservice"
    }
  }
}

resource "aws_codebuild_project" "russ-go-microservice-helm" {
  name         = "russ-go-microservice-helm"
  description  = "Helm deployment for Golang based Microservice"
  service_role = "${aws_iam_role.russ-codebuild-go-microservice.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "${var.deploy_image}"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false

    environment_variable {
      name  = "HELM_ACTION"
      value = "upgrade"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-helm.yaml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "russ-codebuild"
      stream_name = "go-microservice-helm"
    }
  }
}