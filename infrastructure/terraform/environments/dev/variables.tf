# environments/dev/variables.tf
# Root module variables - these are the knobs and dials for configuring your environment

# Core identification variables
variable "project_name" {
  description = "Name of the project, used consistently across all resource naming"
  type        = string
  default     = "k8s-learning"
}

variable "environment" {
  description = "Environment identifier (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-central-1"
}

variable "aws_account_id" {
  description = "AWS Account ID for resource ARN construction"
  type        = string
}

# Network configuration variables
variable "vpc_cidr" {
  description = "CIDR block for the entire VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-central-1a"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (ALB, NAT Gateway)"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (Kubernetes nodes)"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

# Security configuration
variable "k8s_api_allowed_cidrs" {
  description = "CIDR blocks allowed to access Kubernetes API (use carefully in production)"
  type        = string
  default     = "0.0.0.0/0"  # Wide open for learning - restrict this in production!
}

variable "nodeport_cidr_blocks" {
  description = "CIDR blocks allowed to access NodePort services"
  type        = string
  default     = "10.0.0.0/16"  # Default to VPC CIDR
}

# Compute configuration
variable "master_instance_type" {
  description = "EC2 instance type for Kubernetes master node"
  type        = string
  default     = "t3.medium"
}

variable "worker_instance_type" {
  description = "EC2 instance type for Kubernetes worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "worker_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number
  default     = 2
}

variable "master_root_volume_size" {
  description = "Root EBS volume size in GB for master node"
  type        = number
  default     = 30
}

variable "worker_root_volume_size" {
  description = "Root EBS volume size in GB for worker nodes"
  type        = number
  default     = 30
}