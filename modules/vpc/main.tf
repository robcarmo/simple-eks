data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      "Name" = "${var.name_prefix}-vpc"
    },
    var.tags
  )
}

resource "aws_subnet" "public" {
  count = var.num_azs

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block             = cidrsubnet(var.vpc_cidr, 8, count.index)
  vpc_id                 = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = "${var.name_prefix}-public-subnet-${data.aws_availability_zones.available.names[count.index]}"
      "kubernetes.io/role/elb" = "1"
      "kubernetes.io/cluster/${var.cluster_name_tag}" = "shared"
    },
    var.tags
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      "Name" = "${var.name_prefix}-igw"
    },
    var.tags
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    {
      "Name" = "${var.name_prefix}-public-rt"
    },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  count = var.num_azs

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}