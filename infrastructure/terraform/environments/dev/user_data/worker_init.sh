#!/bin/bash
# Kubernetes worker node initialization script

# Set variables from Terraform
CLUSTER_NAME="${cluster_name}"
REGION="${region}"
WORKER_NUMBER="${worker_number}"
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
hostnamectl set-hostname ${CLUSTER_NAME}-worker-${WORKER_NUMBER}

# Add master IP to hosts file for easy reference
echo "${MASTER_IP} ${CLUSTER_NAME}-master" >> /etc/hosts

# Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Log initialization completion
echo "Worker node ${WORKER_NUMBER} initialization completed at $(date)" >> /var/log/k8s-init.log