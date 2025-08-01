# Outputs from the worker EC2 instances

output "worker_instance_ids" {
  description = "List of instance IDs for Kubernetes worker nodes"
  value       = module.k8s_workers[*].id
}

output "worker_private_ips" {
  description = "List of private IP addresses for Kubernetes worker nodes"
  value       = module.k8s_workers[*].private_ip
}

output "worker_instance_states" {
  description = "List of states for Kubernetes worker instances"
  value       = module.k8s_workers[*].instance_state
}

output "workers_ssh_key_parameter_name" {
  description = "SSM Parameter Store name containing the workers SSH private key"
  value       = aws_ssm_parameter.k8s_workers_private_key.name
}