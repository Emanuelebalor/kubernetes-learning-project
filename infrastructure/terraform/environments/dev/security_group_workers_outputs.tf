# Outputs from the worker security group

output "workers_security_group_id" {
  description = "Security group ID for Kubernetes worker nodes"
  value       = module.k8s_workers_sg.security_group_id
}

output "workers_security_group_name" {
  description = "Security group name for Kubernetes worker nodes"
  value       = module.k8s_workers_sg.security_group_name
}