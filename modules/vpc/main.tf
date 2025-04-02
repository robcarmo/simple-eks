# Provides availability zones data for the current region
# Ensure the AWS provider is configured in the root module (e.g., examples/basic-eks)
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Resource
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      "Name" = "${var.name_prefix}-vpc"
      # Add common tags required by EKS if any, although usually applied at subnet/cluster level
    },
    var.tags
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = var.num_azs

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  # Calculate subnet CIDRs based on the VPC CIDR and number of AZs
  # Example: /24 subnets for a /16 VPC, adjust mask/newbits as needed
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index) 
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true # Characteristic of a public subnet

  tags = merge(
    {
      "Name" = "${var.name_prefix}-public-subnet-${data.aws_availability_zones.available.names[count.index]}"
      # Tag required by EKS for automatic discovery of subnets for public load balancers
      "kubernetes.io/role/elb" = "1" 
      # Tag required by EKS for automatic discovery of subnets for the cluster itself (if using shared subnets)
      # Often the cluster tag is applied here too for consistency.
      "kubernetes.io/cluster/${var.cluster_name_tag}" = "shared" 
    },
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      "Name" = "${var.name_prefix}-igw"
    },
    var.tags
  )
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    # Route traffic destined for outside the VPC (0.0.0.0/0) to the Internet Gateway
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

# Public Subnet Route Table Associations
# Associate each public subnet with the public route table
resource "aws_route_table_association" "public" {
  count = var.num_azs

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}