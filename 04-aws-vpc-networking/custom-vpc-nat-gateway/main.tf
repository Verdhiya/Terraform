# ============================================
# EC2 Instances in Custom VPC
# Deploys instance in public subnet with SSH access
# ============================================

# ============================================
# SSH KEY PAIR
# ============================================

# SSH Key Pair for Instance Access
resource "aws_key_pair" "levelup_key" {        # 1. Create SSH key pair
  key_name   = "levelup_key"                   # 2. Key name in AWS
  public_key = file(var.PATH_TO_PUBLIC_KEY)    # 3. Read public key from file

  tags = {                                     # 4. Key pair tags
    Name = "levelup-key"                       # 5. Tag name
  }
}

# ============================================
# EC2 INSTANCE (Public Subnet)
# ============================================

# EC2 Instance in Public Subnet
resource "aws_instance" "MyFirstInstance" {    # 6. Create EC2 instance
  ami                    = lookup(var.AMIS, var.AWS_REGION)  # 7. AMI from map lookup
  instance_type          = "t2.micro"          # 8. Instance type
  key_name               = aws_key_pair.levelup_key.key_name  # 9. SSH key reference
  vpc_security_group_ids = [aws_security_group.levelup_sg.id]  # 10. Security group reference
  subnet_id              = aws_subnet.levelupvpc_public_2.id   # 11. Deploy in public subnet 2

  tags = {                                     # 12. Instance tags
    Name   = "levelup-web-instance"            # 13. Instance name
    Type   = "WebServer"                       # 14. Instance type
    Subnet = "Public"                          # 15. Subnet location
  }
}

# ============================================
# OUTPUTS: EC2 Instance Information
# ============================================

# SSH Key Pair Info
# output "ssh_key_info" {                        # 16. Output SSH key details
#   description = "SSH key pair information"
#   value = {
#     key_name    = aws_key_pair.levelup_key.key_name
#     fingerprint = aws_key_pair.levelup_key.fingerprint
#   }
# }

# EC2 Instance Details
output "instance_info" {                       # 17. Output instance details
  description = "EC2 instance information"
  value = {
    instance_id       = aws_instance.MyFirstInstance.id
    public_ip         = aws_instance.MyFirstInstance.public_ip
    private_ip        = aws_instance.MyFirstInstance.private_ip
    availability_zone = aws_instance.MyFirstInstance.availability_zone
    subnet_id         = aws_instance.MyFirstInstance.subnet_id
  }
}

# SSH Connection Command
output "ssh_connection" {                      # 18. Output SSH command
  description = "SSH connection command"
  value       = "ssh -i levelup_key ${var.INSTANCE_USERNAME}@${aws_instance.MyFirstInstance.public_ip}"
}