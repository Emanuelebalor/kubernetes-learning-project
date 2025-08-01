# Security group for Kubernetes worker nodes
# Workers need different rules as they run the actual container workloads
module "k8s_workers_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-${var.environment}-k8s-workers-sg"
  description = "Security group for Kubernetes worker nodes - controls pod and service access"
  vpc_id      = module.vpc.vpc_id

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