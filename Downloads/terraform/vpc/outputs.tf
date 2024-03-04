output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}
output "public_subnet_ids" {
  value = [for k, v in aws_subnet.public_subnets : aws_subnet.public_subnets[k].id]
}
output "private_subnet_ids" {
  value = [for k, v in aws_subnet.private_subnets : aws_subnet.private_subnets[k].id]
}
