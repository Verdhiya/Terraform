# ============================================
# Provider Configuration
# Primary: AWS CLI credentials (recommended)
# Fallback: Variables (for specific use cases)
# ============================================

terraform {
  required_version = ">= 1.0" # 1. Minimum Terraform version

  required_providers { # 2. Provider requirements
    aws = {
      source  = "hashicorp/aws" # 3. AWS provider source
      version = "~> 6.0"        # 4. Version constraint (6.x.x)
    }
  }
}

# AWS Provider Configuration
provider "aws" {          # 5. AWS provider
  region = var.AWS_REGION # 6. Region from variable

  # Optional: Use variables for credentials (if not using AWS CLI)
  # Uncomment these lines if you need to use variables instead of AWS CLI
  # access_key = var.AWS_ACCESS_KEY
  # secret_key = var.AWS_SECRET_KEY

  # Default tags applied to all resources
  default_tags { # 7. Tags for all resources
    tags = {
      ManagedBy = "Terraform"    # 8. Management tag
      Project   = "Data-Source" # 9. Project tag
    }
  }
}
