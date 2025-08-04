# Network configuration from VPC
variable "private_subnet_ids" {
  description = "List of private subnet IDs where instances will be launched"
  type        = list(string)
}

# Security group IDs from security-groups module
variable "master_security_group_id" {
  description = "Security group ID for the master node"
  type        = string
}

variable "workers_security_group_id" {
  description = "Security group ID for worker nodes"
  type        = string
}

# Instance configuration
variable "master_instance_type" {
  description = "EC2 instance type for Kubernetes master"
  type        = string
  default     = "t3.medium"
}

variable "worker_instance_type" {
  description = "EC2 instance type for Kubernetes workers"
  type        = string
  default     = "t3.medium"
}

variable "worker_count" {
  description = "Number of worker nodes to create"
  type        = number
  default     = 2
}

# Storage configuration
variable "master_root_volume_size" {
  description = "Root volume size in GB for master node"
  type        = number
  default     = 30
}

variable "worker_root_volume_size" {
  description = "Root volume size in GB for worker nodes"
  type        = number
  default     = 30
}

# Project identification
variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
}

# Common tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Optional: specific AMI IDs
variable "master_ami_id" {
  description = "Specific AMI ID for master (leave empty for latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "worker_ami_id" {
  description = "Specific AMI ID for workers (leave empty for latest Amazon Linux 2)"
  type        = string
  default     = ""
}