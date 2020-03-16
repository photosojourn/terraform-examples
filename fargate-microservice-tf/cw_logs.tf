resource "aws_cloudwatch_log_group" "microservice-log-group" {
  name = "microservices"
  retention_in_days = 1
}