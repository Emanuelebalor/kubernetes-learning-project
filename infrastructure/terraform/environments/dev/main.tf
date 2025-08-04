# environments/dev/main.tf
# This is the root module that orchestrates all infrastructure components

# First, we establish local values that will be used across multiple modules
locals {
  # Common naming convention for all resources
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Kubernetes cluster name used for tagging
  kubernetes_cluster_name = "${var.project_name}-${var.environment}-cluster"
  
  # Common tags applied to all resources for consistency
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    CreatedAt   = timestamp()
  }
}

# VPC Module - The foundation of our infrastructure
# This creates all networking components: VPC, subnets, IGW, NAT Gateway
module "vpc" {
  source = "../../modules/vpc"  # Path to module from this directory
  
  # Pass configuration to the VPC module
  project_name            = var.project_name
  environment             = var.environment
  vpc_cidr                = var.vpc_cidr
  primary_availability_zone = var.availability_zones[0]  # Use first AZ from list
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  enable_nat_gateway      = true  # We need this for private instances
  single_nat_gateway      = true  # Cost optimization for learning
  kubernetes_cluster_name = local.kubernetes_cluster_name
  common_tags             = local.common_tags
}

# Security Groups Module - Defines network access rules
# Must be created after VPC exists, but before EC2 instances
module "security_groups" {
  source = "../../modules/security-groups"
  
  # Network context from VPC
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
  
  # Configuration
  project_name          = var.project_name
  environment           = var.environment
  k8s_api_allowed_cidrs = var.k8s_api_allowed_cidrs
  nodeport_cidr_blocks  = var.nodeport_cidr_blocks
  common_tags           = local.common_tags
  
  # Explicit dependency to ensure VPC is created first
  depends_on = [module.vpc]
}

# Compute Module - Creates EC2 instances for Kubernetes nodes
# Depends on both VPC (for networking) and Security Groups (for access rules)
module "compute" {
  source = "../../modules/compute"
  
  # Network configuration from VPC
  private_subnet_ids = module.vpc.private_subnet_ids
  
  # Security configuration from Security Groups module
  master_security_group_id  = module.security_groups.master_security_group_id
  workers_security_group_id = module.security_groups.workers_security_group_id
  
  # Instance configuration
  master_instance_type    = var.master_instance_type
  worker_instance_type    = var.worker_instance_type
  worker_count            = var.worker_count
  master_root_volume_size = var.master_root_volume_size
  worker_root_volume_size = var.worker_root_volume_size
  
  # General configuration
  project_name = var.project_name
  environment  = var.environment
  region       = var.region
  common_tags  = local.common_tags
  
  # Ensure proper creation order
  depends_on = [
    module.vpc,
    module.security_groups
  ]
}
