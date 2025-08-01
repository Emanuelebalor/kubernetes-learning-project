# vpc_outputs.tf - VPC infrastructure outputs for downstream consumption
# This file defines the "API contract" that your VPC infrastructure provides to other components
# Think of outputs as the information your VPC shares with the rest of your infrastructure ecosystem

# Core VPC identification outputs
# These fundamental outputs provide the essential identifiers that other AWS resources need to integrate with your VPC
output "vpc_id" {
  description = "The unique identifier of the VPC - required by security groups, EC2 instances, RDS databases, and all other VPC resources"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The Amazon Resource Name (ARN) of the VPC - required for IAM policies and cross-account resource sharing"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC - essential for security group rules, peering connections, and network planning"
  value       = module.vpc.vpc_cidr_block
}

# Subnet identification outputs
# These outputs enable other modules to understand your network topology and place resources in appropriate subnets
output "public_subnet_ids" {
  description = "List of public subnet IDs - where Application Load Balancers and other internet-facing resources will be deployed"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of all private subnet IDs - encompasses both compute and database subnets for comprehensive resource placement"
  value       = module.vpc.private_subnets
}

output "kubernetes_subnet_ids" {
  description = "Subnet IDs specifically for Kubernetes nodes - the first private subnet dedicated to your cluster infrastructure"
  value       = [module.vpc.private_subnets[0]]
}

output "database_subnet_ids" {
  description = "Subnet IDs for database resources - the second private subnet dedicated to RDS and other data services"
  value       = [module.vpc.private_subnets[1]]
}

# Network routing and connectivity outputs
# These outputs help you understand and troubleshoot your network traffic patterns
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway - provides bidirectional internet connectivity for public subnets"
  value       = module.vpc.igw_id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs - critical for monitoring costs and troubleshooting private subnet internet connectivity"
  value       = module.vpc.natgw_ids
}

output "nat_public_ips" {
  description = "List of Elastic IP addresses used by NAT Gateways - important for firewall whitelisting and external service configuration"
  value       = module.vpc.nat_public_ips
}

# Infrastructure summary output
# This comprehensive output provides a human-readable overview of your VPC architecture
output "vpc_infrastructure_summary" {
  description = "Comprehensive summary of VPC infrastructure for documentation and validation purposes"
  value = {
    vpc_name               = "${var.project_name}-${var.environment}-vpc"
    vpc_id                 = module.vpc.vpc_id
    vpc_cidr               = module.vpc.vpc_cidr_block
    availability_zone      = var.primary_availability_zone
    public_subnets_count   = length(module.vpc.public_subnets)
    private_subnets_count  = length(module.vpc.private_subnets)
    internet_access        = "Enabled via Internet Gateway"
    nat_configuration      = var.single_nat_gateway ? "Single NAT Gateway (cost-optimized)" : "Multiple NAT Gateways (high-availability)"
    kubernetes_ready       = "Yes - subnets tagged for AWS Load Balancer Controller"
    estimated_setup_time   = "2-3 minutes"
    destruction_time       = "1-2 minutes"
  }
}