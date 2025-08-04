# vpc.tf - VPC infrastructure definition for Kubernetes learning project
# This file is responsible solely for VPC and networking infrastructure
# All VPC-related configuration is contained here for easy maintenance and understanding
locals {
  # Construct Kubernetes cluster name if not explicitly provided
  kubernetes_cluster_name = var.kubernetes_cluster_name != "" ? var.kubernetes_cluster_name : "${var.project_name}-${var.environment}"
}
# VPC Module - Creates our foundational networking layer
# Using the official AWS VPC module to establish networking best practices
module "vpc" {
  # Official AWS VPC module from the Terraform Registry
  # Documentation: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"


  # Basic VPC identification and configuration
  # Name combines project and environment for clear identification in AWS Console
  name = "${var.project_name}-${var.environment}-vpc" #No declaration found for "var.project_name" No declaration found for "var.environment"
  cidr = var.vpc_cidr # No declaration found for "var.vpc_cidr"

  # Availability Zone configuration
  # Using single AZ for learning simplicity while maintaining flexibility for future expansion
  azs = [var.primary_availability_zone]

  # Subnet configuration following three-tier architecture pattern
  # Public subnet: hosts resources that need direct internet access (ALB, NAT Gateway)
  # The Internet Gateway is created AUTOMATICALLY when public_subnets are specified
  public_subnets = var.public_subnet_cidrs
  
  # Private subnets: host protected resources (Kubernetes nodes, databases)
  # Separating compute and database subnets follows enterprise security patterns
  private_subnets = var.private_subnet_cidrs

  # NAT Gateway configuration for secure outbound internet access from private subnets
  # This pattern allows private resources to download updates and packages while remaining protected
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  
  # DNS configuration essential for Kubernetes service discovery and inter-pod communication
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # Comprehensive tagging strategy for resource management and cost tracking
  # Tags help with organization, cost allocation, and automated resource management
  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-vpc" # No declaration found for "var.project_name" No declaration found for "var.environment"
    Environment = var.environment #No declaration found for "var.environment"
    Project     = var.project_name #No declaration found for "var.project_name"
  })

  # Kubernetes-specific subnet tagging for AWS Load Balancer Controller integration
  # These tags enable automatic subnet discovery by Kubernetes AWS integrations
  # The Load Balancer Controller uses these tags to determine where to place load balancers
  public_subnet_tags = merge(var.common_tags, {
    Name                                              = "${var.project_name}-${var.environment}-public-subnet"
    Type                                              = "public"
    "kubernetes.io/role/elb"                         = "1"      # Enables ALB placement in this subnet
    "kubernetes.io/cluster/${local.kubernetes_cluster_name}" = "shared"# Indicates subnet is shared by cluster
  })

  private_subnet_tags = merge(var.common_tags, {
    Name                                                      = "${var.project_name}-${var.environment}-private-subnet"
    Type                                                      = "private"
    "kubernetes.io/role/internal-elb"                        = "1"      # Enables internal LB placement
    "kubernetes.io/cluster/${local.kubernetes_cluster_name}" = "shared"# Cluster association for internal services
  })

  # Additional resource-specific tagging for better organization and cost tracking
  # Each networking component gets clear identification for monitoring and troubleshooting
  igw_tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })

  nat_gateway_tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-nat-gateway"
  })

  nat_eip_tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-nat-eip"
  })
}