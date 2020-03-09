resource "aws_s3_bucket" "russ_codepipeline_bucket_go_microservice" {
  bucket = "russ-codepipeline-go-microservice"
  acl    = "private"
}

resource "aws_iam_role" "russ_codepipeline_role_go_microservice" {
  name = "russ_codepipeline_go_microservice"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "russ_codepipeline_policy_go_microservice" {
  name = "russ_codepipeline_policy_go_microservice"
  role = "${aws_iam_role.russ_codepipeline_role_go_microservice.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
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
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_codepipeline" "russ_codepipeline_go_microservice" {
  name     = "russ_go_microservice"
  role_arn = "${aws_iam_role.russ_codepipeline_role_go_microservice.arn}"

  artifact_store {
    type     = "S3"
    location = "${aws_s3_bucket.russ_codepipeline_bucket_go_microservice.bucket}"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "photosojourn"
        Repo       = "go-microservice"
        Branch     = "master"
        OAuthToken = "${var.github_token}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = "russ-go-microservice"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = "russ-go-microservice-helm"
      }
    }
  }
}
