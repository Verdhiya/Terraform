# ============================================
# Security Group with Dynamic IP Ranges
# Uses aws_ip_ranges data source for AWS IPs
# LIMITED to 50 IPs to stay within AWS quota
# ============================================

# ============================================
# DATA SOURCE: AWS IP Ranges
# ============================================

# Query AWS published IP ranges for specific regions and services
data "aws_ip_ranges" "us_east_ip_range" {     # 1. Query AWS IP ranges
  regions  = ["us-east-1"]                    # 2. Filter by region (single region)
  services = ["ec2"]                          # 3. Filter by service (EC2)
}

# ============================================
# RESOURCE: Security Group
# ============================================

# Create security group allowing HTTPS from AWS EC2 IP ranges (LIMITED)
resource "aws_security_group" "us_east_sg" {  # 4. Create security group
  name        = "us-east-sg"                  # 5. Security group name
  description = "Allow HTTPS from AWS EC2 IP ranges (first 50)"  # 6. Description (updated)
  vpc_id      = data.aws_vpc.default.id       # 7. In default VPC

  # HTTPS Inbound Traffic (LIMITED to first 50 IPs)
  ingress {                                   # 8. Inbound rule
    description = "HTTPS from AWS EC2 IP ranges (limited to 50)"  # 9. Rule description
    from_port   = 443                         # 10. HTTPS port
    to_port     = 443                         # 11. HTTPS port
    protocol    = "tcp"                       # 12. TCP protocol
    cidr_blocks = slice(data.aws_ip_ranges.us_east_ip_range.cidr_blocks, 0, 50)  # 13. FIRST 50 IPs ONLY
  }

  # All Outbound Traffic
  egress {                                    # 14. Outbound rule
    description = "All outbound traffic"      # 15. Rule description
    from_port   = 0                           # 16. All ports
    to_port     = 0                           # 17. All ports
    protocol    = "-1"                        # 18. All protocols
    cidr_blocks = ["0.0.0.0/0"]               # 19. To anywhere
  }

  tags = {                                    # 20. Tags
    Name         = "us-east-sg"               # 21. Tag name
    CreationDate = data.aws_ip_ranges.us_east_ip_range.create_date  # 22. IP range publish date
    SyncToken    = data.aws_ip_ranges.us_east_ip_range.sync_token   # 23. IP range version token
    IPCount      = "50 of ${length(data.aws_ip_ranges.us_east_ip_range.cidr_blocks)}"  # 24. Shows limitation
  }
}

# ============================================
# OUTPUT: Security Group Info
# ============================================

output "security_group_info" {                # 25. Output SG details
  description = "Security group information"
  value = {
    id            = aws_security_group.us_east_sg.id
    name          = aws_security_group.us_east_sg.name
    total_ips     = length(data.aws_ip_ranges.us_east_ip_range.cidr_blocks)  # Total found
    used_ips      = 50                        # Actually used
    create_date   = data.aws_ip_ranges.us_east_ip_range.create_date
    aws_sg_limit  = "60 rules max per SG"
  }
}
