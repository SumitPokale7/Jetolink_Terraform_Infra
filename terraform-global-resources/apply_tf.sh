#!/bin/bash

WORKSPACE=${1:-dev}

# Check if sops is installed
if ! command -v sops &> /dev/null; then
    echo "🔧 sops not found. Installing..."
    
    # Download latest SOPS binary
    curl -LO https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64

    # Move it to /usr/local/bin
    sudo mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops

    # Give execute permissions
    sudo chmod +x /usr/local/bin/sops

    echo "✅ sops installed successfully."
else
    echo "✅ sops is already installed: $(sops --version)"
fi

echo "📁 Running terraform init with backend configuration..."
terraform init -backend-config="mgmt.s3.tfbackend"

echo "🛠️  Creating/selecting terraform workspace..."
terraform workspace new ${WORKSPACE} || terraform workspace select ${WORKSPACE}

echo "🔓 Decrypting tfvars/${WORKSPACE}.tfvars in-place..."
sops -d -i tfvars/${WORKSPACE}.tfvars

echo "🔍 Running terraform plan with decrypted tfvars..."
terraform plan -var-file="tfvars/${WORKSPACE}.tfvars"

echo "🚀 Running terraform apply with decrypted tfvars..."
terraform apply -var-file="tfvars/${WORKSPACE}.tfvars --auto-approve"

echo "✅ Done."
