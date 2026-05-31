variable "region" {
  default = "us-east-1"
}

variable "name_prefix" {
  default = "ai-agency"
}

variable "cluster_name" {
  default = "ai-agency-cluster"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "node_availability_zone" {
  default = "us-east-1b"
}


