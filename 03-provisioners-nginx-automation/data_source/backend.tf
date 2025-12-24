# ============================================
# Remote State Backend Configuration
# S3 storage without state locking
# ============================================

terraform {
  backend "s3" {                              # 1. Backend type: S3
    bucket  = "tf-state-learn-001"            # 2. S3 bucket name
    key     = "data-source/terraform.tfstate" # 3. State file path in bucket
    region  = "us-east-1"                     # 4. Bucket region
    encrypt = true                            # 5. Enable encryption
  }
}