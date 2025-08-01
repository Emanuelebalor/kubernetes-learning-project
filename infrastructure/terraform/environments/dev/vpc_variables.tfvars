# vpc_variables.tfvars - Actual values for VPC infrastructure variables
# This file contains the specific configuration values for your development environment
# These values reflect your learning project requirements and eu-central-1 regional setup

primary_availability_zone = "eu-central-1a"

# Subnet segmentation strategy
# One public subnet for internet-facing resources, two private subnets for workload separation
public_subnet_cidrs = [
  "10.0.1.0/24"  # Public subnet for ALB, NAT Gateway, and other internet-facing resources
]

private_subnet_cidrs = [
  "10.0.2.0/24",  # Private subnet for Kubernetes master and worker nodes
  "10.0.3.0/24"   # Private subnet for RDS databases and other data services
]

# NAT Gateway configuration for cost-optimized learning environment
# Single NAT Gateway provides internet access for private subnets while minimizing costs
enable_nat_gateway = true
single_nat_gateway = true

# DNS configuration essential for Kubernetes functionality
# Both settings must be true for proper Kubernetes service discovery and pod communication
enable_dns_hostnames = true
enable_dns_support   = true

# Kubernetes cluster configuration
# This name will be used in resource tags for AWS Load Balancer Controller integration
kubernetes_cluster_name = "k8s-cluster"

# Comprehensive tagging strategy for resource management
# These tags support cost tracking, automation, and clear resource identification
common_tags = {
  ManagedBy   = "terraform"
  Purpose     = "kubernetes-learning"
  Owner       = "devops-student"
  CostCenter  = "learning"
  AutoDestroy = "true"  # Indicates this infrastructure should be destroyed when not in use
}