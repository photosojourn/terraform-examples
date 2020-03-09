resource "aws_ecr_repository" "russ-go-microservice" {
  name                 = "go-microservice"
  image_tag_mutability = "MUTABLE"
}