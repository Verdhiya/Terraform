# ============================================
# EC2 Instance with Data Sources
# Demonstrates querying AWS for dynamic data
# ============================================

# ============================================
# DATA SOURCES (Read-only queries)
# ============================================

# Data Source 1: Get Latest Ubuntu AMI
data "aws_ami" "latest_ubuntu" { # 1. Query for latest Ubuntu AMI
  most_recent = true             # 2. Get most recent match
  owners      = ["099720109477"] # 3. Canonical (Ubuntu) account ID

  filter { # 4. Filter by name pattern
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter { # 5. Filter by architecture
    name   = "architecture"
    values = ["x86_64"]
  }

  filter { # 6. Filter by virtualization type
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data Source 2: Get Current AWS Account Info
data "aws_caller_identity" "current" {} # 7. Get current account ID, ARN, user ID

# Data Source 3: Get Current Region Info
data "aws_region" "current" {} # 8. Get region name and description

# Data Source 4: Get Available Availability Zones
data "aws_availability_zones" "available" { # 9. Query available AZs in region
  state = "available"                       # 10. Only available ones
}

# Data Source 5: Get Default VPC
data "aws_vpc" "default" { # 11. Find default VPC
  default = true           # 12. Get the default VPC
}

# Data Source 6: Get Default Security Group
data "aws_security_group" "default" { # 13. Find default security group
  vpc_id = data.aws_vpc.default.id    # 14. In default VPC
  name   = "default"                  # 15. Named "default"
}

# ============================================
# RESOURCES (Using Data Sources)
# ============================================

# EC2 Instance
resource "aws_instance" "MyFirstinstance" {                               # 16. Create EC2 instance
  ami                    = data.aws_ami.latest_ubuntu.id                  # 17. Use latest Ubuntu AMI from data source
  instance_type          = "t2.micro"                                     # 18. Instance type
  availability_zone      = data.aws_availability_zones.available.names[1] # 19. Deploy in second available AZ
  vpc_security_group_ids = [data.aws_security_group.default.id]           # 20. Use default security group from data source

  tags = {                                           # 21. Instance tags
    Name       = "datasource-demo"                   # 22. Instance name
    DeployedIn = data.aws_region.current.description # 23. Region description from data source
    #    AccountID  = data.aws_caller_identity.current.account_id # 24. Account ID from data source
    AMIUsed = data.aws_ami.latest_ubuntu.name # 25. AMI name from data source
  }
}

# ============================================
# OUTPUTS (Display Data Source Results)
# ============================================

output "ami_info" { # 26. Output AMI information
  description = "Information about the AMI used"
  value = {
    id           = data.aws_ami.latest_ubuntu.id
    name         = data.aws_ami.latest_ubuntu.name
    created      = data.aws_ami.latest_ubuntu.creation_date
    architecture = data.aws_ami.latest_ubuntu.architecture
  }
}

#output "account_info" { # 27. Output account information
#  description = "Current AWS account information"
#  value = {
#    account_id = data.aws_caller_identity.current.account_id
#    user_id    = data.aws_caller_identity.current.user_id
#    arn        = data.aws_caller_identity.current.arn
#  }
#}

output "region_info" { # 28. Output region information
  description = "Current AWS region information"
  value = {
    endpoint    = data.aws_region.current.endpoint
    description = data.aws_region.current.description
  }
}

output "availability_zones" { # 29. Output available AZs
  description = "Available zones in current region"
  value       = data.aws_availability_zones.available.names
}

output "instance_details" { # 30. Output instance information
  description = "Created instance details"
  value = {
    instance_id       = aws_instance.MyFirstinstance.id
    public_ip         = aws_instance.MyFirstinstance.public_ip
    availability_zone = aws_instance.MyFirstinstance.availability_zone
  }
}
