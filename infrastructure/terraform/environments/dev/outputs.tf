# environments/dev/outputs.tf
# Aggregated outputs from all modules for easy reference

# VPC Outputs - Network information you'll need for troubleshooting
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "IDs of private subnets where Kubernetes nodes live"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of public subnets for load balancers"
  value       = module.vpc.public_subnet_ids
}

# Security Group Outputs - For reference and troubleshooting
output "master_security_group_id" {
  description = "Security group ID for Kubernetes master"
  value       = module.security_groups.master_security_group_id
}

output "workers_security_group_id" {
  description = "Security group ID for Kubernetes workers"
  value       = module.security_groups.workers_security_group_id
}

# Compute Outputs - Information needed to access your instances
output "master_instance_id" {
  description = "Instance ID of Kubernetes master"
  value       = module.compute.master_instance_id
}

output "master_private_ip" {
  description = "Private IP of Kubernetes master"
  value       = module.compute.master_private_ip
}

output "worker_instance_ids" {
  description = "Instance IDs of Kubernetes workers"
  value       = module.compute.worker_instance_ids
}

output "worker_private_ips" {
  description = "Private IPs of Kubernetes workers"
  value       = module.compute.worker_private_ips
}

# SSH Key Locations - For retrieving keys when needed
output "master_ssh_key_parameter" {
  description = "AWS SSM Parameter name for master SSH key"
  value       = module.compute.master_ssh_key_parameter_name
}

output "workers_ssh_key_parameter" {
  description = "AWS SSM Parameter name for workers SSH key"  
  value       = module.compute.workers_ssh_key_parameter_name
}

# Summary information for quick reference
output "infrastructure_summary" {
  description = "Quick summary of what was created"
  value = {
    environment    = var.environment
    vpc_id         = module.vpc.vpc_id
    master_ip      = module.compute.master_private_ip
    worker_count   = var.worker_count
    worker_ips     = module.compute.worker_private_ips
  }
}