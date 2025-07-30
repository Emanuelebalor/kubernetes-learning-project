# Makefile for Kubernetes Learning Project
.PHONY: init structure clean help

# Default target
help:
	@echo "Available targets:"
	@echo "  make init      - Create project structure and initial files"
	@echo "  make structure - Create only directory structure"
	@echo "  make clean     - Remove all created directories (careful!)"

# Create complete project structure with initial files
init: structure
	@echo "Creating initial files..."
	@touch .gitignore
	@echo "# Terraform" >> .gitignore
	@echo "*.tfstate" >> .gitignore
	@echo "*.tfstate.*" >> .gitignore
	@echo ".terraform/" >> .gitignore
	@echo ".terraform.lock.hcl" >> .gitignore
	@echo "" >> .gitignore
	@echo "# Environment variables" >> .gitignore
	@echo ".env" >> .gitignore
	@echo "*.env" >> .gitignore
	@echo "" >> .gitignore
	@echo "# AWS credentials" >> .gitignore
	@echo ".aws/" >> .gitignore
	@echo "" >> .gitignore
	@echo "# Kubernetes" >> .gitignore
	@echo "kubeconfig" >> .gitignore
	@echo "*.kubeconfig" >> .gitignore
	@echo "" >> .gitignore
	@echo "# IDE" >> .gitignore
	@echo ".idea/" >> .gitignore
	@echo ".vscode/" >> .gitignore
	@echo "*.swp" >> .gitignore
	@echo "" >> .gitignore
	@echo "# OS" >> .gitignore
	@echo ".DS_Store" >> .gitignore
	@echo "Thumbs.db" >> .gitignore
	@echo "" >> .gitignore
	@echo "# Secrets" >> .gitignore
	@echo "secrets/" >> .gitignore
	@echo "*.pem" >> .gitignore
	@echo "*.key" >> .gitignore
	@echo "✓ Created .gitignore"

# Create directory structure only
structure:
	@echo "Creating project directory structure..."
	@mkdir -p documentation/learning-notes
	@mkdir -p documentation/architecture-decisions
	@mkdir -p documentation/runbooks
	@mkdir -p infrastructure/terraform/environments/dev
	@mkdir -p infrastructure/terraform/environments/prod
	@mkdir -p infrastructure/terraform/modules
	@mkdir -p infrastructure/scripts
	@mkdir -p applications/java-task-api
	@mkdir -p applications/js-dashboard
	@mkdir -p applications/csharp-notification
	@mkdir -p kubernetes/manifests
	@mkdir -p kubernetes/helm-charts
	@mkdir -p kubernetes/argocd
	@mkdir -p ci-cd/.github/workflows
	@mkdir -p observability/prometheus
	@mkdir -p observability/grafana
	@mkdir -p observability/elk
	@echo "✓ Directory structure created"

# Clean all directories (use with caution!)
clean:
	@echo "⚠️  This will remove all project directories!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	rm -rf documentation infrastructure applications kubernetes ci-cd observability
	@echo "✓ Directories removed"