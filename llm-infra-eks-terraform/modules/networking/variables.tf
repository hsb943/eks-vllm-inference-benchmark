variable "vpc_cidr" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "availability_zones" {
  type = list(string)
}
