# Variables specific to the master security group
# These are in addition to the shared variables in variables.tf

variable "k8s_api_allowed_cidrs" {
  description = "CIDR blocks allowed to access the Kubernetes API server"
  type        = string
  default     = "0.0.0.0/0"  # Open during learning, restrict in production
}

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