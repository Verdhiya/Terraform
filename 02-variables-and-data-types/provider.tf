terraform {
  required_version = ">= 1.0" # 1. Check Terraform binary version first

  required_providers { # 2. Then download these providers
    aws = {
      source  = "hashicorp/aws" # 3. AWS provider from HashiCorp registry
      version = "6.25.0"        # 4. Exact AWS provider version
    }
    azurerm = {
      source  = "hashicorp/azurerm" # 5. Azure provider from HashiCorp registry
      version = "4.55.0"            # 6. Exact Azure provider version
    }
  }
}

# AWS Provider Configuration
provider "aws" { # 7. Configure AWS provider
  #  access_key = "${var.AWS_ACCESS_KEY}" # You can mention key here but not recommended, as we have already set up this in aws_cli.
  #  secret_key = "${var.AWS_SECRET_KEY}" # You can mention key here but not recommended, as we have already set up this in aws_cli.
  region = "us-east-1" # 8. Use US East (N. Virginia) region
}

# Azure Provider Configuration
#provider "azurerm" { # 9. Configure Azure provider
#  features {}        # 10. Required empty features block for Azure
#}
