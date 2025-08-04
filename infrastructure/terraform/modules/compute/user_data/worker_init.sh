#!/bin/bash
# Kubernetes worker node initialization script

# Set variables from Terraform
cluster_name="${cluster_name}"
REGION="${region}"
worker_number="${worker_number}"
MASTER_IP="${master_ip}"

# Update system
yum update -y

# Install necessary packages
yum install -y \
    yum-utils \
    device-mapper-persistent-data \
    lvm2 \
    git \
    curl \
    wget

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws/

# Ensure SSM agent is running
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Set hostname
hostnamectl set-hostname ${cluster_name}-worker-${worker_number}

# Add master IP to hosts file for easy reference
echo "${master_ip} ${cluster_name}-master" >> /etc/hosts

# Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Log initialization completion
echo "Worker node ${worker_number} initialization completed at $(date)" >> /var/log/k8s-init.log