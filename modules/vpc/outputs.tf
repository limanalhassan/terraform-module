output "vpcID" {
  value = aws_vpc.dev.id
}

output "public_subnet" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet" {
  value = aws_subnet.private_subnet[*].id
}

output "azs" {
  value = data.aws_availability_zones.azs.names
}