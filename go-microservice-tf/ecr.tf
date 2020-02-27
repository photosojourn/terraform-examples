resource "aws_ecr_repository" "russ-go-microservice" {
  name                 = "russ-go-microservice"
  image_tag_mutability = "MUTABLE"
}