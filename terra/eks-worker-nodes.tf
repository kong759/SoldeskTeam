#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#
# EC2관련 IAM Role을 생성
resource "aws_iam_role" "project-node" {
  name = "terraform-eks-project-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
# 위에서 생성한 IAM Role에 Policy를 추가
resource "aws_iam_role_policy_attachment" "project-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.project-node.name
}

resource "aws_iam_role_policy_attachment" "project-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.project-node.name
}

resource "aws_iam_role_policy_attachment" "project-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.project-node.name
}
# 마지막으로 Node Group을 생성
resource "aws_eks_node_group" "project" {
  cluster_name    = aws_eks_cluster.project.name
  node_group_name = "project"
  node_role_arn   = aws_iam_role.project-node.arn
  subnet_ids      = aws_subnet.terraform-eks-private-subnet[*].id

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.project-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.project-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.project-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
