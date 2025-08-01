# Variables specific to worker EC2 instances

variable "worker_count" {
  description = "Number of Kubernetes worker nodes to create"
  type        = number
  default     = 2
}

variable "worker_instance_type" {
  description = "EC2 instance type for Kubernetes worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "worker_ami_id" {
  description = "Specific AMI ID for worker nodes (leave empty to use latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "worker_root_volume_size" {
  description = "Size of the root volume for worker nodes in GB"
  type        = number
  default     = 30
}

variable "worker_enable_monitoring" {
  description = "Enable detailed monitoring for worker nodes"
  type        = bool
  default     = true
}