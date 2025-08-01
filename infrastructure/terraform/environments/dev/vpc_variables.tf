# vpc_variables.tf - Variable definitions specific to VPC infrastructure
# This file defines all configurable parameters for the VPC module
# Each variable includes validation rules and comprehensive documentation

variable "primary_availability_zone" {
  description = "The primary availability zone for single-AZ deployment - keeps all resources in one AZ for simplicity and cost optimization"
  type        = string
  default     = "eu-central-1a"
  
  validation {
    condition     = length(regexall("^[a-z]{2}-[a-z]+-[0-9][a-z]$", var.primary_availability_zone)) > 0
    error_message = "Availability zone must be in valid AWS format (e.g., us-east-1a)."
  }
}

# Subnet configuration variables
# These variables define how your VPC address space is segmented for different types of resources
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets - where internet-facing resources like ALB and NAT Gateway will be placed"
  type        = list(string)
  default     = ["10.0.1.0/24"]
  
  validation {
    condition     = length(var.public_subnet_cidrs) > 0
    error_message = "At least one public subnet CIDR must be specified."
  }
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets - where protected resources like Kubernetes nodes and databases will be placed"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
  
  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least two private subnet CIDRs must be specified for compute and database separation."
  }
}

# NAT Gateway configuration variables
# These variables control internet access patterns for private subnet resources
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for outbound internet access from private subnets - required for package downloads and updates"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets - cost optimization for non-production environments"
  type        = bool
  default     = true
}

# DNS configuration variables
# These variables enable proper hostname resolution essential for Kubernetes service discovery
variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC - required for proper Kubernetes node and service resolution"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC - provides DNS resolution services within the network"
  type        = bool
  default     = true
}

# Kubernetes integration variables
# These variables support Kubernetes-specific tagging and future cluster configuration
variable "kubernetes_cluster_name" {
  description = "Name of the Kubernetes cluster - used for resource tagging that enables AWS Load Balancer Controller integration"
  type        = string
  default     = "k8s-cluster"
  
  validation {
    condition     = length(var.kubernetes_cluster_name) > 0 && length(var.kubernetes_cluster_name) <= 40
    error_message = "Kubernetes cluster name must be between 1 and 40 characters."
  }
}

# Tagging configuration variables
# These variables establish consistent labeling patterns for resource management and cost tracking
variable "common_tags" {
  description = "Common tags applied to all VPC resources - essential for cost tracking, automation, and resource management"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Purpose   = "kubernetes-learning"
  }
}