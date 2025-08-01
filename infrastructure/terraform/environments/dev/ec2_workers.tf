# Generate SSH key pair for worker nodes (shared among workers)
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

# Attach admin policy to workers - will be refined later
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
  version = "~> 5.0"

  # Using count to create multiple workers
  count = var.worker_count

  name = "${var.project_name}-${var.environment}-k8s-worker-${count.index + 1}"

  # Spot instance configuration
  create_spot_instance              = true
  spot_price                        = ""  # Use market price
  spot_wait_for_fulfillment         = true
  spot_type                         = "persistent"
  spot_instance_interruption_behavior = "stop"

  # Instance configuration
  ami                    = var.worker_ami_id != "" ? var.worker_ami_id : data.aws_ami.amazon_linux_2.id
  instance_type          = var.worker_instance_type
  key_name              = aws_key_pair.k8s_workers_key.key_name
  monitoring            = true
  vpc_security_group_ids = [module.k8s_workers_sg.security_group_id]
  subnet_id             = module.vpc.private_subnets[0]  # All in same subnet as requested
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
  user_data = base64encode(templatefile("${path.module}/user_data/worker_init.sh", {
    cluster_name  = "${var.project_name}-${var.environment}"
    region        = var.region
    worker_number = count.index + 1
    master_ip     = module.k8s_master.private_ip  # Workers need master IP
  }))

  # Ensure workers are created after master and VPC
  depends_on = [
    module.vpc,
    module.k8s_master
  ]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-k8s-worker-${count.index + 1}"
      Type = "kubernetes-worker"
      Role = "worker"
      WorkerNumber = count.index + 1
    }
  )
}