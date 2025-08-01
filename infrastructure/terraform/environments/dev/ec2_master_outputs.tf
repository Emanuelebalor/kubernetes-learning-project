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
}