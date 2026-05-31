# Public routes
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}



# Private routes
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"                    
  nat_gateway_id         = aws_nat_gateway.eks_nat.id    # “For all internet-bound traffic (0.0.0.0/0), send it to a NAT Gateway, not an IGW.”
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
