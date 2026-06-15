# ============================================
# Variable Declarations
# Modern approach with types and validation
# ============================================

# AWS Credentials (Optional - use AWS CLI instead)
variable "AWS_ACCESS_KEY" {                            # 1. Access key variable (optional)
  type        = string                                 # 2. Type: string
  description = "AWS Access Key (use AWS CLI instead)" # 3. Documentation
  default     = ""                                     # 4. Empty default (not required)
  sensitive   = true                                   # 5. Hide in output
}

variable "AWS_SECRET_KEY" {                            # 6. Secret key variable (optional)
  type        = string                                 # 7. Type: string
  description = "AWS Secret Key (use AWS CLI instead)" # 8. Documentation
  default     = ""                                     # 9. Empty default
  sensitive   = true                                   # 10. Hide in output
}

# AWS Region
variable "AWS_REGION" {                    # 11. Region variable
  type        = string                     # 12. Type: string
  description = "AWS region for resources" # 13. Documentation
  default     = "us-east-2"                # 14. Default region

  validation { # 15. Validation rule
    condition     = can(regex("^(us|eu|ap|sa|ca|me|af)-(north|south|east|west|central|northeast|southeast)-[1-9]$", var.AWS_REGION))
    error_message = "Must be a valid AWS region."
  }
}

# Security Groups (Optional - not used in current config)
variable "Security_Group" {                  # 16. Security group list
  type        = list(string)                 # 17. Type: list of strings
  description = "List of security group IDs" # 18. Documentation
  default     = []                           # 19. Empty default (not used)
}

# AMI IDs per Region
variable "AMIS" {                       # 20. AMI map variable
  type        = map(string)             # 21. Type: map of strings
  description = "AMI IDs by AWS region" # 22. Documentation
  default = {                           # 23. AMI mappings
    us-east-1 = "ami-0f40c8f97004632f9" # Amazon Linux 2023
    us-east-2 = "ami-05692172625678b4e" # Amazon Linux 2023
    us-west-1 = "ami-0f40c8f97004632f9" # Amazon Linux 2023
    us-west-2 = "ami-0352d5a37fb4f603f" # Amazon Linux 2023
  }
}

# SSH Key Paths
variable "PATH_TO_PRIVATE_KEY" {               # 24. Private key path
  type        = string                         # 25. Type: string
  description = "Path to SSH private key file" # 26. Documentation
  default     = "levelup_key"                  # 27. Default filename
}

variable "PATH_TO_PUBLIC_KEY" {               # 28. Public key path
  type        = string                        # 29. Type: string
  description = "Path to SSH public key file" # 30. Documentation
  default     = "levelup_key.pub"             # 31. Default filename
}

# Instance Username
variable "INSTANCE_USERNAME" {                  # 32. SSH username variable
  type        = string                          # 33. Type: string
  description = "SSH username for EC2 instance" # 34. Documentation
  default     = "ubuntu"                        # 35. Ubuntu default user

  validation { # 36. Validation rule
    condition     = contains(["ubuntu", "ec2-user", "admin"], var.INSTANCE_USERNAME)
    error_message = "Username must be ubuntu, ec2-user, or admin."
  }
}
