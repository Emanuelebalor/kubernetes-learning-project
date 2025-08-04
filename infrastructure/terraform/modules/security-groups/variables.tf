# Variables specific to the master security group
# These are in addition to the shared variables in variables.tf

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC, often used for internal traffic rules"
  type        = string
}

# Project identification
variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# Kubernetes API access configuration
variable "k8s_api_allowed_cidrs" {
  description = "CIDR blocks allowed to access Kubernetes API server"
  type        = string
  default     = "0.0.0.0/0"  # Open during learning, restrict in production
}

# NodePort service access
variable "nodeport_cidr_blocks" {
  description = "CIDR blocks allowed to access NodePort services"
  type        = string
  default     = "10.0.0.0/16"  # Default to VPC CIDR
}

# Common tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Additional rules for flexibility
variable "master_sg_additional_rules" {
  description = "Additional security group rules for master nodes"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
    description = string
  }))
  default = []
}

variable "workers_sg_additional_rules" {
  description = "Additional security group rules for worker nodes"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
    description = string
  }))
  default = []
}