#!/bin/bash
# Kubernetes master node initialization script

# Set variables from Terraform
CLUSTER_NAME="${cluster_name}"
REGION="${region}"

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

# Install AWS CLI v2 (latest)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws/

# Install SSM agent (should be pre-installed on Amazon Linux 2, but ensure it's running)
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Set hostname
hostnamectl set-hostname ${cluster_name}-master

# Disable swap (required for Kubernetes)
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Log initialization completion
echo "Master node initialization completed at $(date)" >> /var/log/k8s-init.log