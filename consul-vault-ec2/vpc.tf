module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "russ-sm-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # NAT GW's enabled in order to allow access to Docker Hub.
  # Shouldn't be needed if your using ECR for the images. 
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false
  enable_dns_hostnames   = true

  tags = {
    Owner = "Russ W"
  }
}
