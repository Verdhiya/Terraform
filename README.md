# 01 - Terraform Basics

## 📚 What I Learned

### Core Concepts
- Terraform provider configuration
- Resource block syntax
- Basic EC2 instance creation
- Terraform workflow (init → plan → apply → destroy)
- State file management
- Count meta-argument for multiple resources

### Provider Setup
- AWS provider configuration
- Version constraints (`~> 6.0` vs exact versions)
- Region specification
- AWS CLI credential integration
- Multi-cloud setup (AWS + Azure providers in one config)

## 📁 Files in This Project

- `provider.tf` - AWS and Azure provider configuration with version constraints
- `main.tf` - EC2 instance resource with count meta-argument

## 🔧 What I Built

### Infrastructure Created
- **Provider:** AWS (us-east-1) + Azure (configured but not used)
- **Resources:** 3x EC2 instances (t2.micro)
- **AMI:** Ubuntu 24.04 LTS (ami-0ecb62995f68bb549)
- **Tags:** Dynamic naming with count.index

### Configuration Details
```hcl
resource "aws_instance" "MyFirstInstance" {
  count         = 3
  ami           = "ami-0ecb62995f68bb549"
  instance_type = "t2.micro"
  
  tags = {
    Name = "demoinstance-${count.index}"
  }
}
```

## 🚀 Commands I Used

### Setup & Initialization
```bash
terraform init                    # Downloaded AWS provider v6.25.0
terraform fmt                     # Formatted code to standard style
terraform validate                # Validated syntax - Success!
```

### Planning
```bash
terraform plan                    # Previewed infrastructure changes
terraform plan -out=01-basics_plan  # Saved plan to file for review
terraform show 01-basics_plan     # Displayed saved plan details
```

### Deployment
```bash
terraform apply "01-basics_plan"  # Applied saved plan (no re-confirmation)
# Alternative: terraform apply (shows plan again, asks for 'yes')
```

### Verification
```bash
terraform show                    # Viewed created infrastructure
terraform state list              # Listed all 3 instances
terraform state show aws_instance.MyFirstInstance[0]  # Detailed view
ping <public_ip>                  # Tested connectivity (blocked by default SG)
```

### Cleanup
```bash
terraform plan -destroy           # Previewed destruction
terraform destroy                 # Removed all infrastructure
```

## 💡 What I Experienced

### Initial Setup
1. Installed Terraform on Ubuntu VM
2. Configured hostname to "terraform"
3. Set up AWS CLI with access keys
4. Learned about credential security (never hardcode!)

### First Deployment
- Created 3 EC2 instances simultaneously
- Instances: demoinstance-0, demoinstance-1, demoinstance-2
- Each got unique IDs and public IPs
- Total creation time: ~13 seconds

### Results
```
Instance 0: i-0a05f1fcffb58b3f8 (Public IP: 54.227.211.211)
Instance 1: i-03a3a475aad4a068f (Public IP: 34.228.79.54)
Instance 2: i-08063d5199e1871ad (Public IP: 52.7.173.45)
```

### Destruction
- Destroyed all 3 instances
- Total destruction time: ~60 seconds
- Clean state file after removal

## 🐛 Issues I Solved

### Problem 1: Credential Security
**Issue:** Initially hardcoded AWS credentials in provider.tf
```hcl
provider "aws" {
  access_key = "ACCES_KEY"  # ❌ Security risk!
  secret_key = "SECRET_KEY"
}
```

**Solution:** Used AWS CLI credentials
```bash
aws configure  # One-time setup
```
```hcl
provider "aws" {
  region = "us-east-1"  # ✅ No credentials in code!
}
```

### Problem 2: Provider Version Understanding
**Question:** Why specify region in code when AWS CLI already has it?

**Answer Learned:**
- Code should be explicit and portable
- Don't rely on external configuration
- Team members might have different AWS CLI configs
- Infrastructure as Code = everything in code

### Problem 3: Version Constraints
**Learning:** Difference between exact version and constraint
```hcl
version = "6.25.0"    # Exact version
version = "~> 6.0"    # Any 6.x.x (modern approach)
```

**Chose:** Exact version for learning predictability

## 📖 Key Concepts Mastered

### Count Meta-Argument
```hcl
count = 3
tags = {
  Name = "demoinstance-${count.index}"
}
```
**Result:** Creates demoinstance-0, demoinstance-1, demoinstance-2

### State Management
- `terraform.tfstate` - Terraform's memory of infrastructure
- `terraform.tfstate.backup` - Previous state backup
- State tracks: IDs, IPs, configurations, dependencies

### Saved Plans
```bash
terraform plan -out=01-basics_plan  # Save plan
terraform apply "01-basics_plan"    # Execute exact saved plan (no re-confirmation)
```

**Why useful:**
- Review plans before applying
- Team approvals
- CI/CD pipelines
- Guaranteed execution

## 🎓 Skills Gained

### Terraform Workflow
```
1. Write .tf files
2. terraform init (download providers)
3. terraform fmt (format code)
4. terraform validate (check syntax)
5. terraform plan (preview changes)
6. terraform apply (create infrastructure)
7. terraform show (verify created resources)
8. terraform destroy (clean up)
```

### File Organization
- Separate provider config from resources
- Clear naming conventions
- Comments for clarity

### AWS Integration
- Provider authentication via AWS CLI
- EC2 instance creation
- Understanding AMI IDs
- Instance types and free tier

## 📊 What I Created

### Session 1: First Infrastructure
```
Created: 3x t2.micro EC2 instances
Time: 13 seconds
Cost: $0.00 (Free Tier)
Location: us-east-1c
```

### Commands Executed
```
terraform init        ✅ Provider downloaded (v6.25.0)
terraform fmt         ✅ Code formatted
terraform validate    ✅ Syntax valid
terraform plan        ✅ Previewed 3 instances
terraform plan -out   ✅ Saved plan to file
terraform show        ✅ Viewed saved plan
terraform apply       ✅ Created 3 instances
terraform show        ✅ Verified deployment
terraform state list  ✅ Listed all resources
terraform destroy     ✅ Cleaned up (60 seconds)
```

## 💡 Best Practices I Learned

### Security
- ✅ Never hardcode credentials
- ✅ Use AWS CLI for authentication
- ✅ Understand credential priority order
- ✅ Keep state files private

### Code Quality
- ✅ Use terraform fmt for consistent formatting
- ✅ Always validate before planning
- ✅ Comment code for clarity
- ✅ Use numbered file prefixes for order

### Workflow
- ✅ Always preview with plan before apply
- ✅ Save plans for review
- ✅ Verify with terraform show
- ✅ Always destroy test resources

## ⚠️ Challenges Faced

### Challenge 1: Understanding Providers
**Confusion:** Why install provider in each directory?
**Solution:** Each directory is independent project, needs its own provider setup

### Challenge 2: Region Specification
**Question:** Why specify region in code when AWS CLI has it?
**Answer:** Code should be self-contained and portable

### Challenge 3: State Files
**Learning:** What is terraform.tfstate and why important?
**Understanding:** Terraform's mapping of code to real resources

## 📈 My Progress

```
Day 1:
- ✅ Terraform installation
- ✅ AWS CLI configuration  
- ✅ First EC2 instance created
- ✅ Understanding of basic workflow

Skills Level: Beginner → Intermediate
Confidence: Can deploy basic infrastructure independently
```

## 🔗 Repository Navigation

- **Next:** [02-variables-and-data-types](../02-variables-and-data-types/) - Learn dynamic configurations
- **Advanced:** [03-provisioners-nginx-automation](../03-provisioners-nginx-automation/) - Automated server setup

---

**Time Spent:** 2-3 hours  
**Difficulty:** Beginner  
**Resources Created:** 3 EC2 instances  
**Resources Destroyed:** 3 EC2 instances  
**Cost Incurred:** $0.00  
**Knowledge Gained:** Priceless 💎
