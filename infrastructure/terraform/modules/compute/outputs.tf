# Outputs from the master EC2 instance

output "master_instance_id" {
  description = "Instance ID of the Kubernetes master node"
  value       = module.k8s_master.id
}

output "master_private_ip" {
  description = "Private IP address of the Kubernetes master node"
  value       = module.k8s_master.private_ip
}

output "master_instance_state" {
  description = "State of the Kubernetes master instance"
  value       = module.k8s_master.instance_state
}

output "master_ssh_key_parameter_name" {
  description = "SSM Parameter Store name containing the master SSH private key"
  value       = aws_ssm_parameter.k8s_master_private_key.name
}# Outputs from the worker EC2 instances

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