# ============================================
# VPC Infrastructure
# Creates custom VPC with public/private subnets
# ============================================

# ============================================
# DATA SOURCE: Get Available AZs
# ============================================

# Query available AZs in current region (dynamic)
data "aws_availability_zones" "available" {   # 1. Get available AZs
  state = "available"                         # 2. Only available ones
}

# ============================================
# VPC
# ============================================

# Create Custom VPC
resource "aws_vpc" "levelupvpc" {             # 3. Create VPC
  cidr_block           = "10.0.0.0/16"        # 4. VPC IP range (65,536 IPs)
  instance_tenancy     = "default"            # 5. Shared hardware (cost-effective)
  enable_dns_support   = true                 # 6. Enable DNS resolution (FIXED: was string)
  enable_dns_hostnames = true                 # 7. Enable DNS hostnames (FIXED: was string)

  tags = {                                    # 8. VPC tags
    Name = "levelupvpc"                       # 9. VPC name
  }
}

# ============================================
# PUBLIC SUBNETS
# ============================================

# Public Subnet 1
resource "aws_subnet" "levelupvpc_public_1" { # 10. Create public subnet 1
  vpc_id                  = aws_vpc.levelupvpc.id  # 11. Reference VPC
  cidr_block              = "10.0.1.0/24"     # 12. Subnet IP range (256 IPs)
  map_public_ip_on_launch = true              # 13. Auto-assign public IPs (FIXED: was string)
  availability_zone       = data.aws_availability_zones.available.names[0]  # 14. First AZ (dynamic)

  tags = {                                    # 15. Subnet tags
    Name = "levelupvpc-public-1"              # 16. Subnet name
    Type = "Public"                           # 17. Subnet type
  }
}

# Public Subnet 2
resource "aws_subnet" "levelupvpc_public_2" { # 18. Create public subnet 2
  vpc_id                  = aws_vpc.levelupvpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]  # 19. Second AZ (dynamic)

  tags = {
    Name = "levelupvpc-public-2"
    Type = "Public"
  }
}

# Public Subnet 3
resource "aws_subnet" "levelupvpc_public_3" { # 20. Create public subnet 3
  vpc_id                  = aws_vpc.levelupvpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[2]  # 21. Third AZ (dynamic)

  tags = {
    Name = "levelupvpc-public-3"
    Type = "Public"
  }
}

# ============================================
# PRIVATE SUBNETS
# ============================================

# Private Subnet 1
resource "aws_subnet" "levelupvpc_private_1" {  # 22. Create private subnet 1
  vpc_id                  = aws_vpc.levelupvpc.id
  cidr_block              = "10.0.4.0/24"      # 23. Private IP range
  map_public_ip_on_launch = false              # 24. No public IPs (FIXED: was string)
  availability_zone       = data.aws_availability_zones.available.names[0]  # 25. First AZ (matches public-1)

  tags = {
    Name = "levelupvpc-private-1"
    Type = "Private"                           # 26. Subnet type tag
  }
}

# Private Subnet 2
resource "aws_subnet" "levelupvpc_private_2" {  # 27. Create private subnet 2
  vpc_id                  = aws_vpc.levelupvpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]  # 28. Second AZ

  tags = {
    Name = "levelupvpc-private-2"
    Type = "Private"
  }
}

# Private Subnet 3
resource "aws_subnet" "levelupvpc_private_3" {  # 29. Create private subnet 3
  vpc_id                  = aws_vpc.levelupvpc.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[2]  # 30. Third AZ

  tags = {
    Name = "levelupvpc-private-3"
    Type = "Private"
  }
}

# ============================================
# INTERNET GATEWAY
# ============================================

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "levelup_gw" {  # 31. Create Internet Gateway
  vpc_id = aws_vpc.levelupvpc.id                # 32. Attach to VPC

  tags = {                                      # 33. IGW tags
    Name = "levelup-gw"                         # 34. IGW name
  }
}

# ============================================
# ROUTE TABLE (Public)
# ============================================

# Route Table for Public Subnets
resource "aws_route_table" "levelup_public" {  # 35. Create public route table
  vpc_id = aws_vpc.levelupvpc.id               # 36. For this VPC

  route {                                      # 37. Default route
    cidr_block = "0.0.0.0/0"                   # 38. All internet traffic
    gateway_id = aws_internet_gateway.levelup_gw.id  # 39. Via Internet Gateway
  }

  tags = {                                     # 40. Route table tags
    Name = "levelup-public-rt"                 # 41. Route table name
  }
}

# ============================================
# ROUTE TABLE ASSOCIATIONS (Public Subnets)
# ============================================

# Associate Public Subnet 1 with Route Table
resource "aws_route_table_association" "levelup_public_1_a" {  # 42. Associate subnet 1
  subnet_id      = aws_subnet.levelupvpc_public_1.id           # 43. Public subnet 1
  route_table_id = aws_route_table.levelup_public.id           # 44. Public route table
}

# Associate Public Subnet 2 with Route Table
resource "aws_route_table_association" "levelup_public_2_a" {  # 45. Associate subnet 2
  subnet_id      = aws_subnet.levelupvpc_public_2.id
  route_table_id = aws_route_table.levelup_public.id
}

# Associate Public Subnet 3 with Route Table
resource "aws_route_table_association" "levelup_public_3_a" {  # 46. Associate subnet 3
  subnet_id      = aws_subnet.levelupvpc_public_3.id
  route_table_id = aws_route_table.levelup_public.id
}