output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "private_subnet_ids_by_az" {
  value = {
    for subnet in aws_subnet.private_subnets : subnet.availability_zone => subnet.id...
  }
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}
