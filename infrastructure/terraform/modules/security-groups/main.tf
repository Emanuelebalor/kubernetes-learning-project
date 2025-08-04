# Security group for Kubernetes master node
# This module creates the networking rules that control traffic to/from the master
module "k8s_master_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-${var.environment}-k8s-master-sg"
  description = "Security group for Kubernetes master node - controls API server and etcd access"
  vpc_id = var.vpc_id  # Reference the VPC we created in Phase 1

  # Ingress rules - what traffic can reach the master
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access for administration"
      cidr_blocks = var.vpc_cidr  # Only allow SSH from within VPC
    },
    {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      description = "Kubernetes API server - main entry point for kubectl"
      cidr_blocks = "0.0.0.0/0"  # Initially open, will restrict later
    },
    {
      from_port   = 2379
      to_port     = 2380
      protocol    = "tcp"
      description = "etcd server client API and peer communication"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      description = "Kubelet API - master needs to reach kubelets"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 10259
      to_port     = 10259
      protocol    = "tcp"
      description = "kube-scheduler health check"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 10257
      to_port     = 10257
      protocol    = "tcp"
      description = "kube-controller-manager health check"
      cidr_blocks = var.vpc_cidr
    }
  ]

  # Egress rules - what traffic can leave the master
  # Using the pre-defined "all-all" rule for simplicity during learning
  egress_rules = ["all-all"]

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-k8s-master-sg"
      Type        = "kubernetes-master"
      Environment = var.environment
    }
  )
}# Security group for Kubernetes worker nodes
# Workers need different rules as they run the actual container workloads
module "k8s_workers_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-${var.environment}-k8s-workers-sg"
  description = "Security group for Kubernetes worker nodes - controls pod and service access"
  vpc_id = var.vpc_id

  # Ingress rules for worker nodes
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access for administration"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      description = "Kubelet API - for master to worker communication"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 30000
      to_port     = 32767
      protocol    = "tcp"
      description = "NodePort services range - where K8s exposes services"
      cidr_blocks = var.vpc_cidr
    }
  ]

  # Worker-to-worker communication for pod networking
  # This uses the 'self' reference, meaning the SG refers to itself
  ingress_with_self = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "Allow all TCP traffic between workers for pod communication"
    },
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "udp"
      description = "Allow all UDP traffic between workers for pod communication"
    }
  ]

  # Workers also need to reach the master's API server
  # We'll use computed rules that reference the master SG
  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 65535
      protocol                 = "tcp"
      source_security_group_id = module.k8s_master_sg.security_group_id
      description              = "Allow all TCP from master for cluster operations"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-k8s-workers-sg"
      Type        = "kubernetes-worker"
      Environment = var.environment
    }
  )
}