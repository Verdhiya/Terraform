# 🚀 My Terraform Learning Journey

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

## 📚 About This Repository

This repository documents my hands-on learning experience with **Terraform** and **AWS Cloud Infrastructure**. I started from absolute basics and progressively built real-world infrastructure automation skills.

## 🎯 What I Learned

### Infrastructure as Code (IaC)
- ✅ Automated infrastructure provisioning with code
- ✅ Version-controlled infrastructure
- ✅ Repeatable and consistent deployments
- ✅ Infrastructure lifecycle management

### Terraform Mastery
- ✅ Provider configuration (AWS)
- ✅ Resource creation and management
- ✅ Variable types (string, list, map)
- ✅ Map lookups for dynamic configurations
- ✅ Provisioners for server configuration
- ✅ State management
- ✅ Terraform workflow and commands

### AWS Cloud Platform
- ✅ EC2 instance deployment
- ✅ Security group configuration
- ✅ SSH key pair management
- ✅ Data sources (AMI, AZs, VPC, IP ranges) for dynamic config
- ✅ Remote state backend (S3, encrypted)
- ✅ Custom VPC: public/private subnets, IGW, NAT Gateway, route tables
- ✅ Multi-AZ network design
- ✅ Free tier optimization (and knowing what is NOT free tier)

## 📂 Learning Path

```
terraform-learning/
├── 01-terraform-basics/                  # Started here: Providers & Basic EC2
├── 02-variables-and-data-types/          # Learned: Variables, Maps, Dynamic Config
├── 03-provisioners-nginx-automation/     # Mastered: Provisioners & Nginx automation
│   └── data_source/                      # Data sources + S3 remote state backend
└── 04-aws-vpc-networking/                # Built: Custom VPC, subnets, IGW + NAT Gateway
    └── custom-vpc-nat-gateway/
```

## 🛠️ Technologies Used

- **Terraform** v1.9.8 - Infrastructure as Code
- **AWS** - Cloud platform (Free Tier)
- **AWS CLI** v2.32.13 - AWS authentication
- **Ubuntu** 24.04 LTS - Operating system
- **Nginx** - Web server
- **Bash** - Shell scripting

## 💪 Skills Gained

### Terraform Commands Mastered
```bash
terraform init              # Initialize and download providers
terraform fmt               # Format code to standard style
terraform validate          # Validate configuration syntax
terraform plan              # Preview infrastructure changes
terraform plan -out=file    # Save plan to file
terraform show              # Display current state or plan
terraform apply             # Create/update infrastructure
terraform apply "planfile"  # Apply saved plan
terraform destroy           # Remove all infrastructure
terraform state list        # List all resources in state
terraform state show        # Show specific resource details
terraform console           # Interactive console for testing
```

### Problems I Solved

**1. Credential Management**
- ❌ Started with hardcoded credentials (security risk)
- ✅ Learned AWS CLI configuration (best practice)
- ✅ Understood credential precedence

**2. Variable Usage**
- ❌ Initially tried `ami = var.AMIS` (type mismatch error)
- ✅ Fixed with map lookup: `ami = var.AMIS[var.AWS_REGION]`
- ✅ Understood map vs string types

**3. Security Groups**
- ❌ Used fake security group IDs (would fail)
- ✅ Created security groups in Terraform
- ✅ Understood reference vs creation

**4. SSH Key Generation**
- ❌ Terraform failed - public key file didn't exist
- ✅ Generated keys with `ssh-keygen -t rsa -b 4096 -f levelup_key -N ""`
- ✅ Understood public/private key concepts

**5. Connection Blocks**
- ❌ Duplicate connection blocks in each provisioner
- ✅ Optimized with single connection at resource level
- ✅ Applied DRY principles

## 🏆 Projects Completed

### Project 1: Basic EC2 Deployment
**What I Did:**
- Configured AWS provider
- Created EC2 instance (t2.micro)
- Used count meta-argument for multiple instances
- Tested plan → apply → destroy workflow

**Commands Used:**
```bash
terraform init
terraform fmt
terraform validate
terraform plan -out=01-basics_plan
terraform show 01-basics_plan
terraform apply "01-basics_plan"
terraform destroy
```

### Project 2: Dynamic Variables
**What I Did:**
- Declared string, list, and map variables
- Implemented regional AMI mapping
- Used lookup function for dynamic AMI selection
- Tested variable overrides via command-line

**Commands Used:**
```bash
terraform plan -var="AWS_REGION=us-west-2"
terraform plan -var="AWS_REGION=us-east-2"
terraform console  # Tested var.AMIS, var.AMIS[var.AWS_REGION]
```

### Project 3: Nginx Web Server Automation
**What I Did:**
- Generated SSH keys (RSA 4096-bit)
- Created security group with SSH and HTTP rules
- Deployed EC2 instance with nginx
- Used file provisioner to upload script
- Used remote-exec provisioner to install nginx
- Verified live web server with curl

**Result:**
- ✅ Live nginx server deployed successfully
- ✅ Fully automated deployment (90 seconds)
- ✅ Successful SSH connection and provisioning
- ✅ Clean destruction (21 seconds)

### Project 4: Data Sources & Remote State (03/data_source)
**What I Did:**
- Used 7 data sources (AMI, caller identity, region, AZs, VPC, SG, IP ranges)
- Replaced hardcoded AMIs with dynamic `aws_ami` lookup
- Used `slice()` to stay within the 60-rule/SG limit
- Migrated state to an encrypted S3 backend (`tf-state-learn-001`)

**Result:**
- ✅ Zero hardcoded values in the configuration
- ✅ Remote state in S3 (encrypted, versioned)

### Project 5: Custom VPC with NAT Gateway (04)
**What I Did:**
- Built a custom VPC (`10.0.0.0/16`) with 3 public + 3 private subnets across 3 AZs
- Created Internet Gateway, NAT Gateway + Elastic IP, and public/private route tables
- Deployed an EC2 instance into a public subnet with a security group

**Result:**
- ✅ 21 resources, full multi-AZ network foundation
- ⚠️ NAT Gateway is **not** free tier — see Cost & Security Notes below

## 💰 Cost & Security Notes

> Read this before running `04` — it can generate real charges.

**Cost**
- `01`–`03` stay within the AWS Free Tier (t2.micro, default networking).
- **`04` is NOT free tier.** A **NAT Gateway** costs ~$0.045/hr (~$32/month) **plus** data-processing charges, and bills even while idle. The Elastic IP is free only while attached to a running NAT Gateway.
- Always run `terraform destroy` when you finish a `04` session, and set a billing/budget alert.

**Security (learning-only shortcuts)**
- Security groups in `03` and `04` allow SSH (22) — and HTTP/HTTPS — from `0.0.0.0/0`. This is fine for short-lived labs but is **not** safe for anything real.
- For real use: restrict port 22 to your own IP (`<your-ip>/32`) or use AWS SSM Session Manager (no open SSH port at all).
- The S3 backend uses encryption but no state locking — solo use only; add DynamoDB (or TF ≥1.10 `use_lockfile`) for team use.

## 📈 Progress Timeline

**Total Learning Time:** 4+ days  
**Projects Completed:** 5  
**Infrastructure Deployments:** 7+  
**Lines of Terraform Code:** ~1,100  
**AWS Resources Created:** 30+  
**Errors Debugged:** 10+  
**Concepts Mastered:** 50+

## 🔐 Security Practices Followed

- ✅ No hardcoded credentials in code
- ✅ AWS CLI for credential management
- ✅ Sensitive variables marked properly
- ✅ SSH private keys never committed
- ✅ State files in .gitignore
- ✅ terraform.tfvars excluded from Git

## 🎓 Key Takeaways

### What Infrastructure as Code Means
- Write infrastructure in code files
- Version control your infrastructure
- Automate provisioning and configuration
- Make infrastructure repeatable and consistent

### Why Terraform
- Multi-cloud support (AWS, Azure, GCP)
- Declarative syntax (describe what you want)
- State management (tracks real infrastructure)
- Large provider ecosystem
- Industry standard for IaC

### Real-World Application
This knowledge prepares me for:
- DevOps Engineer roles
- Cloud Engineer positions
- Infrastructure Automation
- CI/CD pipeline development
- Multi-cloud deployments

## 📊 Repository Stats

- **Top-level sections:** 4
- **Terraform Files:** 17
- **Total Lines:** ~1,100+
- **Documentation:** 6 README files
- **Scripts:** 1 (installNginx.sh)

## 🤝 Contributing

This is a personal learning repository. Feel free to fork and use for your own learning!

---

⭐ **Star this repo if you're learning Terraform too!**

---

**Last Updated:** June 2026  
