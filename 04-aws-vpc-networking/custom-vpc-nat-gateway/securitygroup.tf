# ============================================
# Security Group for Custom VPC
# Basic SSH, HTTP, HTTPS access
# ============================================

# ============================================
# SECURITY GROUP: Basic Web Access
# ============================================

# Security Group for Instances in Custom VPC
resource "aws_security_group" "levelup_sg" {   # 1. Create security group
  name        = "levelup-sg"                   # 2. Security group name
  description = "Allow SSH, HTTP, and HTTPS"   # 3. Description
  vpc_id      = aws_vpc.levelupvpc.id          # 4. In custom VPC

  # SSH Access
  ingress {                                    # 5. Inbound rule: SSH
    description = "SSH from anywhere"          # 6. Rule description
    from_port   = 22                           # 7. SSH port
    to_port     = 22                           # 8. SSH port
    protocol    = "tcp"                        # 9. TCP protocol
    cidr_blocks = ["0.0.0.0/0"]                # 10. From anywhere
  }

  # HTTP Access
  ingress {                                    # 11. Inbound rule: HTTP
    description = "HTTP from anywhere"         # 12. Rule description
    from_port   = 80                           # 13. HTTP port
    to_port     = 80                           # 14. HTTP port
    protocol    = "tcp"                        # 15. TCP protocol
    cidr_blocks = ["0.0.0.0/0"]                # 16. From anywhere
  }

  # HTTPS Access
  ingress {                                    # 17. Inbound rule: HTTPS
    description = "HTTPS from anywhere"        # 18. Rule description
    from_port   = 443                          # 19. HTTPS port
    to_port     = 443                          # 20. HTTPS port
    protocol    = "tcp"                        # 21. TCP protocol
    cidr_blocks = ["0.0.0.0/0"]                # 22. From anywhere
  }

  # All Outbound Traffic
  egress {                                     # 23. Outbound rule
    description = "All outbound traffic"       # 24. Rule description
    from_port   = 0                            # 25. All ports
    to_port     = 0                            # 26. All ports
    protocol    = "-1"                         # 27. All protocols
    cidr_blocks = ["0.0.0.0/0"]                # 28. To anywhere
  }

  tags = {                                     # 29. Tags
    Name = "levelup-sg"                        # 30. Tag name
  }
}

# ============================================
# OUTPUT: Security Group Info
# ============================================

output "security_group_info" {                 # 31. Output SG details
  description = "Security group information"
  value = {
    id          = aws_security_group.levelup_sg.id
    name        = aws_security_group.levelup_sg.name
    description = aws_security_group.levelup_sg.description
    vpc_id      = aws_security_group.levelup_sg.vpc_id
  }
}
