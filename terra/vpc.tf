#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "project" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "terraform-eks-project-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}
#public subnet
resource "aws_subnet" "terraform-eks-public-subnet" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.project.id

  tags = tomap({
    "Name"                                      = "terraform-eks-public-${count.index+1 == 1 ? "a" : "c"}",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}
#private subnet
resource "aws_subnet" "terraform-eks-private-subnet" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index+3}.0/24"
  vpc_id                  = aws_vpc.project.id

  tags = tomap({
    "Name"                                      = "terraform-eks-private-${count.index+3 == 3 ? "a" : "c"}",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}
# Create IGW
resource "aws_internet_gateway" "terraform-eks-igw" {
  vpc_id = aws_vpc.project.id

  tags = {
    Name = "terraform-eks-project-igw"
  }
}
# Create EIP for Nat Gateway
resource "aws_eip" "terraform-eks-EIP" {
  vpc   = true
  lifecycle {
        create_before_destroy = true
    }
}
# Create Nat Gateway
resource "aws_nat_gateway" "terraform-eks-ng" {
  allocation_id = aws_eip.terraform-eks-EIP.id
  subnet_id     = aws_subnet.terraform-eks-public-subnet.0.id

  tags = {
    Name = "terraform-eks-project-ng"
  }
}
# create Public Route table
resource "aws_route_table" "terraform-eks-public-route" {
  vpc_id = aws_vpc.project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-eks-igw.id
  }
  tags = {
    "Name" = "terraform-eks-public-route"
  }
}
# Create Private Route Table
resource "aws_route_table" "terraform-eks-private-route" {
  vpc_id = aws_vpc.project.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform-eks-ng.id
  }
  tags = {
    "Name" = "terraform-eks-private-route"
  }
}
# Create Public Route Table Routing
resource "aws_route_table_association" "terraform-eks-public-routing" {
  count = 2

  subnet_id      = aws_subnet.terraform-eks-public-subnet.*.id[count.index]
  route_table_id = aws_route_table.terraform-eks-public-route.id
}
# Create Private Route Table Routing
resource "aws_route_table_association" "terraform-eks-private-routing" {
  count = 2

  route_table_id = aws_route_table.terraform-eks-private-route.id
  subnet_id      = aws_subnet.terraform-eks-private-subnet.*.id[count.index]
}