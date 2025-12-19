# ============================================
# EC2 Instance Resource
# Uses variables for flexibility
# ============================================

resource "aws_instance" "MyFirstInstance" { # 1. Declare EC2 instance resource
  #  count         = 3                          # 2. Create 3 identical instances
  ami             = var.AMIS[var.AWS_REGION] # 3. Ubuntu, 24.04 AMI (us-east-1, x86_64)
  instance_type   = "t2.micro"               # 4. Instance size (1 vCPU, 1GB RAM, Free Tier)
  security_groups = var.Security_Group       # 3. Using list variable!
  tags = {                                   # 5. Resource labels for identification
    Name = "demoinstance"                    # 6. Name with index, use this "demoinstance-${count.index}" for 2 or more (demoinstance-0, demoinstance-1, demoinstance-2)
  }
}
