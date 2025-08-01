# Variables specific to the worker security group

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

variable "nodeport_cidr_blocks" {
  description = "CIDR blocks allowed to access NodePort services"
  type        = string
  default     = "10.0.0.0/16"  # Default to VPC CIDR
}