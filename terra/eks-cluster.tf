#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

# IAM Role을 생성
resource "aws_iam_role" "project-cluster" {
  name = "terraform-eks-project-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# 위에서 생성한 IAM Role에 policy를 추가한다.
resource "aws_iam_role_policy_attachment" "project-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.project-cluster.name
}

resource "aws_iam_role_policy_attachment" "project-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.project-cluster.name
}
# security group을 생성
resource "aws_security_group" "project-cluster" {
  name        = "terraform-eks-project-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.project.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-project"
  }
}
# security group의 ingress 룰을 추가한다.
resource "aws_security_group_rule" "project-cluster-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.project-cluster.id
  to_port           = 443
  type              = "ingress"
}
# 마지막으로 cluster를 생성
resource "aws_eks_cluster" "project" {
  name     = var.cluster-name
  role_arn = aws_iam_role.project-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.project-cluster.id]
    subnet_ids         = concat(aws_subnet.terraform-eks-public-subnet[*].id, aws_subnet.terraform-eks-private-subnet[*].id)
    endpoint_private_access = true
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.project-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.project-cluster-AmazonEKSVPCResourceController,
  ]
}
