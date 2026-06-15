# ============================================
# NAT Gateway Infrastructure
# Enables private subnets to access internet
# ============================================

# ============================================
# ELASTIC IP (for NAT Gateway)
# ============================================

# Elastic IP for NAT Gateway (static IP)
resource "aws_eip" "levelup_nat" {             # 1. Create Elastic IP
  domain = "vpc"                               # 2. For use in VPC (FIXED: was vpc = true - deprecated)

  tags = {                                     # 3. EIP tags
    Name = "levelup-nat-eip"                   # 4. EIP name
  }

  depends_on = [aws_internet_gateway.levelup_gw]  # 5. Create IGW first
}

# ============================================
# NAT GATEWAY
# ============================================

# NAT Gateway (allows private subnets to reach internet)
resource "aws_nat_gateway" "levelup_nat_gw" {  # 6. Create NAT Gateway
  allocation_id = aws_eip.levelup_nat.id       # 7. Attach Elastic IP
  subnet_id     = aws_subnet.levelupvpc_public_1.id  # 8. Deploy in public subnet 1 (FIXED: naming)

  tags = {                                     # 9. NAT Gateway tags
    Name = "levelup-nat-gw"                    # 10. NAT Gateway name
  }

  depends_on = [aws_internet_gateway.levelup_gw]  # 11. Requires IGW to exist first
}

# ============================================
# ROUTE TABLE (Private Subnets)
# ============================================

# Route Table for Private Subnets (routes through NAT)
resource "aws_route_table" "levelup_private" { # 12. Create private route table
  vpc_id = aws_vpc.levelupvpc.id               # 13. For this VPC

  route {                                      # 14. Default route
    cidr_block     = "0.0.0.0/0"               # 15. All internet traffic
    nat_gateway_id = aws_nat_gateway.levelup_nat_gw.id  # 16. Via NAT Gateway (FIXED: naming)
  }

  tags = {                                     # 17. Route table tags
    Name = "levelup-private-rt"                # 18. Route table name
    Type = "Private"                           # 19. Route table type
  }
}

# ============================================
# ROUTE TABLE ASSOCIATIONS (Private Subnets)
# ============================================

# Associate Private Subnet 1 with Private Route Table
resource "aws_route_table_association" "levelup_private_1_a" {  # 20. Associate private subnet 1 (FIXED: was "level")
  subnet_id      = aws_subnet.levelupvpc_private_1.id           # 21. Private subnet 1 (FIXED: naming)
  route_table_id = aws_route_table.levelup_private.id           # 22. Private route table (FIXED: naming)
}

# Associate Private Subnet 2 with Private Route Table
resource "aws_route_table_association" "levelup_private_2_a" {  # 23. Associate private subnet 2 (FIXED: was "1-b")
  subnet_id      = aws_subnet.levelupvpc_private_2.id           # 24. Private subnet 2 (FIXED: naming)
  route_table_id = aws_route_table.levelup_private.id
}

# Associate Private Subnet 3 with Private Route Table
resource "aws_route_table_association" "levelup_private_3_a" {  # 25. Associate private subnet 3 (FIXED: was "1-c")
  subnet_id      = aws_subnet.levelupvpc_private_3.id           # 26. Private subnet 3 (FIXED: naming)
  route_table_id = aws_route_table.levelup_private.id
}