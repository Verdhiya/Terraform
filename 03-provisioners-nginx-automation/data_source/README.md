# Data Sources & Remote State Backend

## 📑 Table of Contents
- [What You'll Learn](#-what-youll-learn)
- [Architecture Overview](#-architecture-overview)
- [Step-by-Step Journey](#-step-by-step-journey)
- [Final Results](#-final-results)
- [Key Learnings](#-key-learnings)
- [Commands Reference](#-commands-reference)

---

## 🎯 What You'll Learn

### Data Sources (7 Types)
- ✅ `aws_ami` - Find latest AMIs automatically
- ✅ `aws_caller_identity` - Get AWS account information
- ✅ `aws_region` - Query current region metadata
- ✅ `aws_availability_zones` - List available AZs dynamically
- ✅ `aws_vpc` - Find existing VPCs
- ✅ `aws_security_group` - Reference existing security groups
- ✅ `aws_ip_ranges` - AWS published IP address ranges

### Remote State Backend
- ✅ S3 backend configuration
- ✅ State migration from local to S3
- ✅ Encryption and versioning
- ✅ State verification commands

### Real-World Skills
- ✅ Working within AWS quotas (60 rules/SG limit)
- ✅ Using slice() function to limit data
- ✅ Troubleshooting AWS API errors
- ✅ Zero-hardcoded infrastructure
- ✅ Production-ready state management

---

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────┐
│           Terraform Configuration               │
│  ┌──────────────┐         ┌─────────────┐      │
│  │ Data Sources │────────►│  Resources  │      │
│  │ (7 queries)  │         │ (2 created) │      │
│  └──────────────┘         └─────────────┘      │
│         │                        │              │
│         │                        │              │
│         ▼                        ▼              │
│  ┌──────────────────────────────────────┐      │
│  │     AWS (us-east-1)                  │      │
│  │  • Latest Ubuntu AMI                 │      │
│  │  • 6 Availability Zones              │      │
│  │  • Default VPC & Security Group      │      │
│  │  • 268 AWS IP Ranges                 │      │
│  │  • EC2 Instance (created)            │      │
│  │  • Custom Security Group (created)   │      │
│  └──────────────────────────────────────┘      │
└─────────────────────────────────────────────────┘
                     │
                     ▼
           ┌─────────────────┐
           │   S3 Bucket     │
           │ tf-state-learn  │
           │   -001          │
           │                 │
           │ ┌─────────────┐ │
           │ │terraform    │ │
           │ │.tfstate     │ │
           │ │(36KB)       │ │
           │ └─────────────┘ │
           │                 │
           │ • Encrypted     │
           │ • Versioned     │
           └─────────────────┘
```

---

## 📝 Step-by-Step Journey

### Step 1: Initial Setup

**Created basic files:**
- provider.tf (AWS provider with default_tags)
- variables.tf (AWS credentials, region, AMIS map)
- main.tf (Simple EC2 instance, no data sources)

**Initialized:** `terraform init`
**Result:** Downloaded AWS provider v6.27.0 ✅

---

### Step 2: Adding AMI Data Source

**Added to main.tf:**
```hcl
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-24.04-lts-amd64-server-*"]
  }
}
```

**Ran:** `terraform plan`

**❌ Error:** Your query returned no results

**Fix:** Made filter broader
```hcl
values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
```

**Result:** ✅ Found AMI: ami-0030e4319cbf4dbf2

---

### Step 3: Adding More Data Sources

**Added 5 more data sources:**
- aws_caller_identity (account info)
- aws_region (region metadata)
- aws_availability_zones (available AZs)
- aws_vpc (default VPC)
- aws_security_group (default security group)

**Updated EC2 instance to use data sources:**
```hcl
ami                    = data.aws_ami.latest_ubuntu.id
availability_zone      = data.aws_availability_zones.available.names[1]
vpc_security_group_ids = [data.aws_security_group.default.id]
```

---

### Step 4: Adding Outputs

**Created outputs for data source results:**
- ami_info
- account_info (later removed)
- region_info
- availability_zones
- instance_details

**⚠️ Warning:** Deprecated attribute `data.aws_region.current.name`

**Fix:** Changed to `data.aws_region.current.endpoint`

---

### Step 5: Creating securitygroup.tf with aws_ip_ranges

**Initial version:**
```hcl
data "aws_ip_ranges" "us_east_ip_range" {
  regions  = ["us-east-1", "us-east-2"]
  services = ["ec2"]
}

resource "aws_security_group" "us_east_sg" {
  ingress {
    cidr_blocks = data.aws_ip_ranges.us_east_ip_range.cidr_blocks  # All 343 IPs
  }
}
```

**Ran:** `terraform apply`

**❌ Error:** RulesPerSecurityGroupLimitExceeded

**What happened:**
- 343 CIDR blocks = 343 rules
- AWS limit = 60 rules per SG
- Instance created, security group failed

**Action:** `terraform destroy`

---

### Step 6: Reducing IP Ranges - Attempt 2

**Changed to single region:**
```hcl
regions = ["us-east-1"]  # Reduced from 2 regions
```

**Ran:** `terraform plan`
**Saw:** 268 CIDR blocks (still exceeds limit)

**Didn't apply** - would fail again

---

### Step 7: Final Fix - slice() Function

**Applied slice() to limit:**
```hcl
cidr_blocks = slice(data.aws_ip_ranges.us_east_ip_range.cidr_blocks, 0, 50)
```

**Added documentation:**
```hcl
tags = {
  IPCount = "50 of ${length(data.aws_ip_ranges.us_east_ip_range.cidr_blocks)}"
}
```

**Result:** ✅ Plan shows 50 IPs (within 60 limit)

---

### Step 8: Creating S3 Backend

**Created S3 bucket in AWS Console:**
- Name: tf-state-learn-001
- Region: us-east-1
- Versioning: Enabled
- Encryption: SSE-S3
- Public access: Blocked

**Created backend.tf:**
```hcl
terraform {
  backend "s3" {
    bucket  = "tf-state-learn-001"
    key     = "data-source/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
```

---

### Step 9: Initializing Backend

```bash
terraform init
```

**Output:** Successfully configured the backend "s3"!

**Checked S3:** Empty (uploads on first apply)

---

### Step 10: Cleaning Variables

**Removed unused variables:**
- Security_Group (commented out)
- AMIS (replaced with data source - commented out)

**Kept:**
- AWS_REGION (actively used)
- AWS credentials (optional fallback)

---

### Step 11: Removing Sensitive Data

**Removed:**
- output "account_info" block
- AccountID from instance tags

**Why:** Sensitive information (account ID, user details)

---

### Step 12: Final Apply

```bash
terraform apply
```

**Result:**
- 7 data sources queried successfully
- 2 resources created (instance + security group)
- 5 outputs displayed
- State uploaded to S3 ✅

---

### Step 13: Verifying Remote State

```bash
aws s3 ls s3://tf-state-learn-001/data-source/
```

**Result:** terraform.tfstate present (36KB)

```bash
terraform state pull
```

**Result:** Downloaded from S3 successfully

**Confirmed:** Terraform using S3, not local file

---

## 🎊 Final Results

### Infrastructure Created
```
1. EC2 Instance
   - AMI: ami-0030e4319cbf4dbf2 (latest Ubuntu from data source)
   - AZ: us-east-1b (from data source)
   - Security Group: Default (from data source)

2. Security Group
   - Name: us-east-sg
   - Rules: 50 CIDR blocks (from aws_ip_ranges)
   - Total IPs found: 268 (limited with slice())
```

### Remote State
```
✅ Stored in: s3://tf-state-learn-001/data-source/terraform.tfstate
✅ Size: 36KB
✅ Encryption: Enabled
✅ Versioning: Enabled
```

---

## 💡 Key Learnings

### Data Sources
- READ-ONLY queries
- Always get current/latest data
- No hardcoding needed
- Queried fresh every plan/apply

### AWS Quotas
- Security groups: Max 60 rules
- Each CIDR = 1 rule
- Use slice() to limit data

### Remote State
- State in S3, not local machine
- Team collaboration ready
- Encrypted and versioned
- Accessible from anywhere

### Functions
- `slice(list, start, end)` - Limit arrays
- `length(list)` - Count items
- `lookup(map, key)` - Map lookups

---

## 🐛 Errors I Fixed

**AMI Filter Too Specific → Made broader**
**343 IP Ranges Exceeded Limit → Reduced to single region**
**268 Still Exceeded → Added slice() to limit to 50**
**Backend Region Mismatch → Fixed to us-east-1**
**Deprecated Attribute → Changed to current attribute**

---

## 🔧 Commands Reference

```bash
# Data Sources
terraform plan                # Queries data sources
terraform console             # Test data source values

# Remote State
terraform init                # Configure backend
terraform state pull          # Download from S3
aws s3 ls s3://bucket/path/   # View in S3

# Troubleshooting
terraform fmt                 # Format code
terraform validate            # Check syntax
terraform plan -out=plan      # Save plan
```

---

**Time Invested:** 1-2 hours  
**Difficulty:** Intermediate-Advanced  
**Real-World Readiness:** Production-level patterns 🚀
