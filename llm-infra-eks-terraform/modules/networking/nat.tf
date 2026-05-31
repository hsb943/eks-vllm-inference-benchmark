resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
}
