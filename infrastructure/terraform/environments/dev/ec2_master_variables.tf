# Variables specific to the master EC2 instance

variable "master_instance_type" {
  description = "EC2 instance type for Kubernetes master node"
  type        = string
  default     = "t3.medium"
}

variable "master_ami_id" {
  description = "Specific AMI ID for master node (leave empty to use latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "master_root_volume_size" {
  description = "Size of the root volume for master node in GB"
  type        = number
  default     = 30
}

variable "master_enable_monitoring" {
  description = "Enable detailed monitoring for master node"
  type        = bool
  default     = true
}