resource "aws_subnet" "public_subnets" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)  # cidr_block = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = var.availability_zones[count.index]
}
