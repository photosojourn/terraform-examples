variable "region" {
  default = "eu-west-1"
}

variable "app_port" {
  default = 3000
}

variable "fargate_memory" {
  default = "512"
}

variable "fargate_cpu" {
  default = "256" 
}

variable "app_count" {
  default = 1 
}

