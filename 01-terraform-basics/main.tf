# ============================================
# AWS EC2 Instance Creation
# Purpose: Create multiple EC2 instances
# Instance: 3x t2.micro (Free Tier)
# ============================================

resource "aws_instance" "MyFirstInstance" { # 1. Declare EC2 instance resource
  count         = 3                         # 2. Create 3 identical instances
  ami           = "ami-0ecb62995f68bb549"   # 3. Ubuntu, 24.04 AMI (us-east-1, x86_64)
  instance_type = "t2.micro"                # 4. Instance size (1 vCPU, 1GB RAM, Free Tier)

  tags = {                               # 5. Resource labels for identification
    Name = "demoinstance-${count.index}" # 6. Name with index (demoinstance-0, demoinstance-1, demoinstance-2)
  }
}
