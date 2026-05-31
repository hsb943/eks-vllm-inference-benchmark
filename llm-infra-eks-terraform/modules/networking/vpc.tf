resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}


# Terraform evaluates this after substitution as if it were:
# resource "aws_vpc" "eks_vpc" {
#  cidr_block = "10.0.0.0/16"
#
#  tags = {
#    Environment = "dev"
#    Project     = "ai-agency"
#    Name        = "ai-agency-vpc"
#  }
#}


