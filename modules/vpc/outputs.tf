output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the created VPC"
  value       = aws_vpc.main.cidr_block
}
