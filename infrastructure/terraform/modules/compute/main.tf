# modules/compute/main.tf - EC2 instances for Kubernetes cluster

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
resource "aws_ssm_parameter" "k8s_master_private_key" {
  name        = "/${var.project_name}/${var.environment}/k8s/master/ssh-private-key"
  description = "SSH private key for Kubernetes master node"
  type        = "SecureString"
  value       = tls_private_key.k8s_master_key.private_key_pem

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-master-ssh-key"
      Type = "kubernetes-master"
    }
  )
}

# IAM role for the master node
resource "aws_iam_role" "k8s_master_role" {
  name = "${var.project_name}-${var.environment}-k8s-master-role"

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

# Attach admin policy to the role
resource "aws_iam_role_policy_attachment" "k8s_master_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.k8s_master_role.name
}

# Create instance profile
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

locals {
  # Use the data source AMI for all instances
  master_ami = data.aws_ami.amazon_linux_2.id
  worker_ami = data.aws_ami.amazon_linux_2.id
}

# The master EC2 instance using the official module
module "k8s_master" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"  # Using v4 to avoid the SSM parameter issues

  name = "${var.project_name}-${var.environment}-k8s-master"

  # Spot instance configuration
  create_spot_instance              = true
  spot_price                        = ""
  spot_wait_for_fulfillment         = true
  spot_type                         = "persistent"
  spot_instance_interruption_behavior = "stop"

  # Instance configuration
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.master_instance_type
  key_name              = aws_key_pair.k8s_master_key.key_name
  monitoring            = true
  vpc_security_group_ids = [var.master_security_group_id]
  subnet_id             = var.private_subnet_ids[0]
  iam_instance_profile  = aws_iam_instance_profile.k8s_master_profile.name
  
  associate_public_ip_address = false

  # Root volume configuration
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = var.master_root_volume_size
      throughput  = 125
      iops        = 3000
    }
  ]

  # User data script
  user_data_base64 = base64encode(templatefile("${path.module}/user_data/master_init.sh", {
    cluster_name = "${var.project_name}-${var.environment}"
    region       = var.region
  }))

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-master"
      Type = "kubernetes-master"
      Role = "master"
    }
  )

  volume_tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-master-volumes"
      Type = "kubernetes-master"
    }
  )
}

# Generate SSH key pair for worker nodes
resource "tls_private_key" "k8s_workers_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair for workers
resource "aws_key_pair" "k8s_workers_key" {
  key_name   = "${var.project_name}-${var.environment}-k8s-workers-key"
  public_key = tls_private_key.k8s_workers_key.public_key_openssh

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-workers-key"
      Type = "kubernetes-worker"
    }
  )
}

# Store the workers private key in Parameter Store
resource "aws_ssm_parameter" "k8s_workers_private_key" {
  name        = "/${var.project_name}/${var.environment}/k8s/workers/ssh-private-key"
  description = "SSH private key for Kubernetes worker nodes"
  type        = "SecureString"
  value       = tls_private_key.k8s_workers_key.private_key_pem

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-workers-ssh-key"
      Type = "kubernetes-worker"
    }
  )
}

# IAM role for worker nodes
resource "aws_iam_role" "k8s_workers_role" {
  name = "${var.project_name}-${var.environment}-k8s-workers-role"

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
      Name = "${var.project_name}-${var.environment}-k8s-workers-role"
      Type = "kubernetes-worker"
    }
  )
}

# Attach admin policy to workers
resource "aws_iam_role_policy_attachment" "k8s_workers_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.k8s_workers_role.name
}

# Instance profile for workers
resource "aws_iam_instance_profile" "k8s_workers_profile" {
  name = "${var.project_name}-${var.environment}-k8s-workers-profile"
  role = aws_iam_role.k8s_workers_role.name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-workers-profile"
      Type = "kubernetes-worker"
    }
  )
}

# Worker instances using count to create multiple instances
module "k8s_workers" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"  # Using v4 to avoid the SSM parameter issues

  count = var.worker_count

  name = "${var.project_name}-${var.environment}-k8s-worker-${count.index + 1}"

  # Spot instance configuration
  create_spot_instance              = true
  spot_price                        = ""
  spot_wait_for_fulfillment         = true
  spot_type                         = "persistent"
  spot_instance_interruption_behavior = "stop"

  # Instance configuration
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.worker_instance_type
  key_name              = aws_key_pair.k8s_workers_key.key_name
  monitoring            = true
  vpc_security_group_ids = [var.workers_security_group_id]
  subnet_id             = var.private_subnet_ids[0]
  iam_instance_profile  = aws_iam_instance_profile.k8s_workers_profile.name

  associate_public_ip_address = false

  # Root volume configuration
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = var.worker_root_volume_size
      throughput  = 125
      iops        = 3000
    }
  ]

  # User data with worker-specific configuration
  user_data_base64 = base64encode(templatefile("${path.module}/user_data/worker_init.sh", {
    cluster_name  = "${var.project_name}-${var.environment}"
    region        = var.region
    worker_number = count.index + 1
    master_ip     = module.k8s_master.private_ip
  }))

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-worker-${count.index + 1}"
      Type = "kubernetes-worker"
      Role = "worker"
      WorkerNumber = count.index + 1
    }
  )

  volume_tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-worker-${count.index + 1}-volumes"
      Type = "kubernetes-worker"
    }
  )
}