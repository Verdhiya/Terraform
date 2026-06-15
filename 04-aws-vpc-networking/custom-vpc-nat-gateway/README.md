# Custom VPC with NAT Gateway

> #### ⚠️ Cost & Security Warning — read before `terraform apply`
>
> **This project is NOT free tier.**
> - **NAT Gateway** ≈ $0.045/hr (~$32/month) **+ data-processing charges**, billed even while idle.
> - **Elastic IP** is free only while attached to a running NAT Gateway; an unattached EIP is billed.
> - **Always run `terraform destroy` when you finish**, and set a billing/budget alert.
>
> **Security (lab-only shortcuts):**
> - The security group opens SSH (22), HTTP (80) and HTTPS (443) to `0.0.0.0/0` (the whole internet). This is convenient for learning, **not** safe for real workloads.
> - For real use: restrict port 22 to your own IP (`<your-ip>/32`) or use AWS SSM Session Manager instead of an open SSH port.

## 📚 What I Learned

### VPC & Networking Concepts
- VPC creation with custom CIDR blocks
- Public vs Private subnet design
- Multi-AZ architecture for high availability
- Internet Gateway for public subnet internet access
- NAT Gateway for private subnet outbound internet
- Route tables and route table associations
- Security groups in custom VPC
- EC2 deployment in specific subnets

### AWS Networking Components
- VPC (Virtual Private Cloud)
- Subnets (Public and Private)
- Internet Gateway (IGW)
- NAT Gateway (for private subnet internet)
- Elastic IP (for NAT Gateway)
- Route Tables (public and private routing)
- Security Groups (firewall rules)

## 📁 Files I Created

- `vpc.tf` - VPC, 6 subnets (3 public + 3 private), Internet Gateway, route tables
- `nat.tf` - NAT Gateway, Elastic IP, private route table
- `securitygroup.tf` - Security group with SSH, HTTP, HTTPS rules
- `main.tf` - EC2 instance, SSH key pair, outputs
- `provider.tf` - AWS provider with default tags
- `variables.tf` - All variable declarations
- `levelup_key` / `levelup_key.pub` - Used existing SSH keys created earlier

## 🔧 What I Built

### Network Architecture

```
VPC: 10.0.0.0/16 (65,536 IPs)
│
├── Public Subnets (Internet-accessible)
│   ├── 10.0.1.0/24 (us-east-2a) - 256 IPs
│   ├── 10.0.2.0/24 (us-east-2b) - 256 IPs
│   └── 10.0.3.0/24 (us-east-2c) - 256 IPs
│   └─► Internet Gateway → Internet
│
├── Private Subnets (No direct internet)
│   ├── 10.0.4.0/24 (us-east-2a) - 256 IPs
│   ├── 10.0.5.0/24 (us-east-2b) - 256 IPs
│   └── 10.0.6.0/24 (us-east-2c) - 256 IPs
│   └─► NAT Gateway (in public subnet) → Internet
│
└── Resources Created
    ├── EC2 Instance (in public subnet 2)
    └── Security Group (SSH, HTTP, HTTPS)
```

### Infrastructure Components

**1. VPC**
```hcl
resource "aws_vpc" "levelupvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}
```

**2. Public Subnets (3)**
```hcl
# Each in different AZ for high availability
cidr_blocks: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
map_public_ip_on_launch = true
```

**3. Private Subnets (3)**
```hcl
# Each in different AZ matching public subnets
cidr_blocks: 10.0.4.0/24, 10.0.5.0/24, 10.0.6.0/24
map_public_ip_on_launch = false
```

**4. Internet Gateway**
```hcl
# Allows public subnets to access internet
Attached to: VPC
```

**5. NAT Gateway**
```hcl
# Allows private subnets outbound internet access
Location: Public Subnet 1
Elastic IP: Attached
```

**6. Security Group**
```hcl
# Firewall rules for EC2 instances
Ingress: SSH (22), HTTP (80), HTTPS (443)
Egress: All traffic
```

**7. EC2 Instance**
```hcl
# Deployed in public subnet 2
AMI: Amazon Linux 2023 (from map lookup)
Type: t2.micro (Free tier)
```

## 🚀 Commands I Used

### File Creation
```bash
# Created modernized files
vim vpc.tf
vim nat.tf
vim securitygroup.tf
vim main.tf
vim provider.tf
vim variables.tf

# Used existing SSH keys created earlier
cp ../data_source/levelup_key .
cp ../data_source/levelup_key.pub .
```

### Terraform Workflow
```bash
terraform init       # Downloaded provider v6.27.0
terraform fmt        # Formatted code
terraform validate   # Validated configuration
terraform plan       # Previewed 21 resources
terraform apply      # Created infrastructure
terraform destroy    # Cleaned up
```

## 💡 What I Experienced

### VPC Creation
**First resource created:** VPC (12 seconds)
**Then parallel:** All subnets created simultaneously
**Network foundation:** Ready for other resources

### NAT Gateway (Slowest Resource)
**Creation time:** 84 seconds
**Why slow:** AWS provisions physical network device
**Purpose:** Private instances can download updates/packages

### Resource Dependencies
**Terraform automatically ordered:**
```
VPC → Subnets → Internet Gateway → Elastic IP
                              ↓
                    NAT Gateway (needs subnet + IGW)
                              ↓
                    Route Tables → Associations
                              ↓
                    Security Group → EC2 Instance
```

### Destruction Order
**Terraform reversed the order:**
```
Route Associations → Route Tables → NAT Gateway → 
Subnets → EIP → IGW → VPC
```

## 📊 What I Created

### Resources Created (21 Total)
```
Network Infrastructure:
- 1 VPC (vpc-xxxxxxxxxxxxxxxxx)
- 3 Public Subnets (in us-east-2a/b/c)
- 3 Private Subnets (in us-east-2a/b/c)
- 1 Internet Gateway
- 1 Elastic IP
- 1 NAT Gateway
- 2 Route Tables (public + private)
- 6 Route Table Associations

Security & Compute:
- 1 Security Group
- 1 SSH Key Pair
- 1 EC2 Instance
```

## 📖 Key Concepts Mastered

### VPC Components
```
VPC = Isolated network in AWS cloud
Subnets = Subdivisions of VPC IP range
Public Subnet = Has route to Internet Gateway
Private Subnet = Has route to NAT Gateway only
CIDR = IP address range notation (10.0.0.0/16)
```

### High Availability
```
Multi-AZ deployment = Resources across 3 availability zones
Why: If one AZ fails, others continue working
Pattern: 1 public + 1 private subnet per AZ
```

### NAT Gateway Purpose
```
Problem: Private instances need internet (updates, downloads)
Solution: NAT Gateway in public subnet
How it works:
  Private instance → NAT Gateway → Internet Gateway → Internet
  (outbound only, no inbound from internet)
```

### Route Tables
```
Public Route Table:
  0.0.0.0/0 → Internet Gateway (all traffic to internet)

Private Route Table:
  0.0.0.0/0 → NAT Gateway (all traffic via NAT)
```

### Data Source for AZs
```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

# Use dynamically:
availability_zone = data.aws_availability_zones.available.names[0]
```

**Benefits:**
- Works in any region
- Automatically adapts to available AZs
- No hardcoded zone names needed

## 🎓 Skills I Gained

### Network Design
- ✅ Plan IP address ranges (CIDR blocks)
- ✅ Design multi-AZ architecture
- ✅ Separate public/private workloads
- ✅ Configure routing between subnets
- ✅ Implement secure network architecture

### Terraform Organization
- ✅ Separate files by resource type (vpc.tf, nat.tf, etc.)
- ✅ Logical file structure
- ✅ Reusable configurations
- ✅ Clean code organization

### AWS Resource Management
- ✅ Understand VPC components
- ✅ Configure NAT for private subnets
- ✅ Manage Elastic IPs
- ✅ Associate route tables correctly
- ✅ Deploy instances in specific subnets

## 💡 Best Practices Applied

### Network Design
- ✅ /16 for VPC (65,536 IPs - room to grow)
- ✅ /24 for subnets (256 IPs each - standard)
- ✅ Multi-AZ deployment (high availability)
- ✅ Public/private separation (security)
- ✅ DNS enabled (service discovery)

### Security
- ✅ Private subnets for backend services
- ✅ NAT Gateway (outbound only — no direct inbound internet to private subnets)
- ✅ SSH key authentication (no passwords)
- ⚠️ Security group is **open to `0.0.0.0/0`** on 22/80/443 for learning — this is NOT least privilege. Lock port 22 to your own IP (or use SSM) before using this for anything real.

### Tagging
- ✅ Default tags on all resources (ManagedBy, Project, Environment)
- ✅ Type tags for subnets (Public/Private)
- ✅ Descriptive names for all resources

### Code Quality
- ✅ Detailed inline comments (every line)
- ✅ Separated concerns (different files)
- ✅ Consistent naming (underscores)
- ✅ Modern Terraform syntax
- ✅ Data sources for dynamic values

## 🧪 Testing & Verification

### Verify in AWS Console
```
1. VPC Dashboard - See custom VPC
2. Subnets - 6 subnets across 3 AZs
3. Internet Gateways - levelup-gw attached
4. NAT Gateways - levelup-nat-gw in public subnet
5. Route Tables - 2 tables with correct routes
6. Security Groups - levelup-sg with rules
7. EC2 Instances - Instance in public subnet 2
```

### SSH to Instance
```bash
ssh -i levelup_key ubuntu@<PUBLIC_IP>

# Check internet connectivity
ping -c 3 google.com

# Exit
exit
```

## 📈 Infrastructure Complexity

```
Compared to previous projects:
├── 01-basics: 1-3 EC2 instances
├── 02-variables: 1 EC2 instance (variables)
├── 03-provisioners: 3 resources (SG, key, instance)
└── 04-vpc-nat: 21 resources (complete network!) 🚀

Skill level: Beginner → Advanced
```

## 💪 What I Can Do Now

- ✅ Design custom VPC networks from scratch
- ✅ Plan IP address ranges (CIDR blocks)
- ✅ Implement multi-AZ architectures
- ✅ Configure NAT Gateways for private subnet internet
- ✅ Create complex routing configurations
- ✅ Deploy instances in specific network locations
- ✅ Manage network security with security groups
- ✅ Build production-ready network foundations

---

**Time Spent:** 1-2 hours  
**Difficulty:** Advanced  
**Resources Created:** 21  
**Real-World Skill:** Production-ready VPC networking 🚀
