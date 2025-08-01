# Generate SSH key pair for the master node
resource "tls_private_key" "k8s_master_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair from the generated public key
resource "aws_key_pair" "k8s_master_key" {
  key_name   = "${var.project_name}-${var.environment}-k8s-master-key"
  public_key = tls_private_key.k8s_master_key.public_key_openssh

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-master-key"
      Type = "kubernetes-master"
    }
  )
}

# Store the private key in AWS Systems Manager Parameter Store
# This keeps it secure and accessible when needed
resource "aws_ssm_parameter" "k8s_master_private_key" {
  name        = "/${var.project_name}/${var.environment}/k8s/master/ssh-private-key"
  description = "SSH private key for Kubernetes master node"
  type        = "SecureString"  # Encrypted at rest
  value       = tls_private_key.k8s_master_key.private_key_pem

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-master-ssh-key"
      Type = "kubernetes-master"
    }
  )
}

# IAM role for the master node - currently with admin access
resource "aws_iam_role" "k8s_master_role" {
  name = "${var.project_name}-${var.environment}-k8s-master-role"

  # This trust policy allows EC2 instances to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-master-role"
      Type = "kubernetes-master"
    }
  )
}

# Attach admin policy to the role - will be refined later
resource "aws_iam_role_policy_attachment" "k8s_master_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.k8s_master_role.name
}

# Create instance profile - this is what actually gets attached to the EC2 instance
resource "aws_iam_instance_profile" "k8s_master_profile" {
  name = "${var.project_name}-${var.environment}-k8s-master-profile"
  role = aws_iam_role.k8s_master_role.name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-master-profile"
      Type = "kubernetes-master"
    }
  )
}

# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# The master EC2 instance using the official module
module "k8s_master" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "${var.project_name}-${var.environment}-k8s-master"

  # Spot instance configuration
  create_spot_instance              = true
  spot_price                        = ""  # Empty string means use current market price
  spot_wait_for_fulfillment         = true
  spot_type                         = "persistent"
  spot_instance_interruption_behavior = "stop"

  # Instance configuration
  ami                    = var.master_ami_id != "" ? var.master_ami_id : data.aws_ami.amazon_linux_2.id
  instance_type          = var.master_instance_type
  key_name              = aws_key_pair.k8s_master_key.key_name
  monitoring            = true
  vpc_security_group_ids = [module.k8s_master_sg.security_group_id]
  subnet_id             = module.vpc.private_subnets[0]  # First private subnet
  iam_instance_profile  = aws_iam_instance_profile.k8s_master_profile.name

  # Disable public IP since we're in a private subnet
  associate_public_ip_address = false

  # Root volume configuration
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = var.master_root_volume_size
      throughput  = 125
      iops        = 3000
      tags = merge(
        var.common_tags,
        {
          Name = "${var.project_name}-${var.environment}-k8s-master-root"
          Type = "kubernetes-master"
        }
      )
    }
  ]

  # User data script for initial setup
  user_data = base64encode(templatefile("${path.module}/user_data/master_init.sh", {
    cluster_name = "${var.project_name}-${var.environment}"
    region       = var.region
  }))

  # This is crucial - ensures the instance is created after VPC resources exist
  depends_on = [
    module.vpc
  ]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-master"
      Type = "kubernetes-master"
      Role = "master"
    }
  )
}