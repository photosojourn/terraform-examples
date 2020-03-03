variable "region" {
  default = "eu-west-1"
}

variable "app_port" {
  default = 8080
}

variable "fargate_memory" {
  default = "512"
}

variable "fargate_cpu" {
  default = "256" 
}

variable "app_count" {
  default = 2
}

variable "go_app_image" {
  default = "photosojourn/go-microservice:latest"
}

variable "node_app_image" {
  default = "photosojourn/node-microservice:latest"
}