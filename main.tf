resource "aws_vpc" "vpc" {
    cidr_block = "10.10.0.0/16"

    tags = {
        Name = "vpc"
    }
}
resource "aws_subnet" "public_subnet-1" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.10.1.0/24"
    availability_zone = "us-east-2a"
    tags = {
        Name = "public_subnet-1"
    }
}

resource "aws_subnet" "public_subnet-2" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.10.2.0/24"
    availability_zone = "us-east-2b"
    tags = {
        Name = "public_subnet-2"
    }
}


resource "aws_subnet" "private_subnet-1" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.10.123.0/24"
    availability_zone = "us-east-2a"
    tags = {
        Name = "private_subnet-1"
    }
}

resource "aws_subnet" "private_subnet-2" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.10.124.0/24"
    availability_zone = "us-east-2b"
    tags = {
        Name = "private_subnet-2"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "Internet Gateway"
    }
}

resource "aws_eip" "EIP" {
    vpc   = true
}

resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.EIP.id
    subnet_id     = aws_subnet.public_subnet-1.id

    tags = {
        Name = "NAT Gateway"
    }
}

resource "aws_default_route_table" "public_rt" {
    default_route_table_id = aws_vpc.vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "public route table"
    }
}

resource "aws_route_table_association" "public_rta_a" {
    subnet_id      = aws_subnet.public_subnet-1.id
    route_table_id = aws_default_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_b" {
    subnet_id      = aws_subnet.public_subnet-2.id
    route_table_id = aws_default_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "private route table"
    }
}

resource "aws_route_table_association" "private_rta_a" {
    subnet_id      = aws_subnet.private_subnet-1.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rta_b" {
    subnet_id      = aws_subnet.private_subnet-2.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route" "private_rt_route" {
    route_table_id              = aws_route_table.private_rt.id
    destination_cidr_block      = "0.0.0.0/0"
    nat_gateway_id              = aws_nat_gateway.ngw.id
}
resource "aws_default_security_group" "SG" {
    vpc_id = aws_vpc.vpc.id

    ingress {
        protocol    = "tcp"
        from_port = 0
        to_port   = 65535
        cidr_blocks = [aws_vpc.vpc.cidr_block]
    }

    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "SG"
        Description = "default security group"
    }
}

resource "aws_security_group" "public-SG1" {
    name        = "public-SG1"
    description = "security group for public subnet"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        description = "For http port"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "For https port"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "public_SG1"
    }
}
resource "aws_alb" "ALB-1" {
  name = "ALB-1"
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.public-SG1.id ]
  subnets = [ aws_subnet.public_subnet-1.id , aws_subnet.public_subnet-2.id ]
  
}
resource "aws_alb_target_group" "TG" {
  name = "TG"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_lb_listener" "ALB-1_listener" {
    load_balancer_arn = aws_alb.ALB-1.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.TG.arn
  }
}



