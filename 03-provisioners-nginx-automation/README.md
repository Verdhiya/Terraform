# 03 - Provisioners, Nginx Automation & Data Sources

## 📚 What This Directory Contains

This directory covers two major Terraform concepts:

1. **Main Folder** - Provisioners and automated nginx deployment
2. **data_source/** - Data sources and remote state backend (S3)

---

## 📁 Directory Structure

```
03-provisioners-nginx-automation/
├── README.md (this file)
├── main.tf (nginx automation with provisioners)
├── provider.tf
├── variables.tf
├── installNginx.sh
│
└── data_source/ (Sub-project)
    ├── README.md (detailed data source journey)
    ├── backend.tf (S3 remote state)
    ├── main.tf (using data sources)
    ├── provider.tf
    ├── variables.tf
    └── securitygroup.tf (aws_ip_ranges data source)
```

---

# 📘 Part 1: Provisioners & Nginx Automation

## 📚 What I Learned

### Advanced Terraform Concepts
- SSH key pair resource creation (aws_key_pair)
- Security group resource creation (aws_security_group)
- Provisioners: file and remote-exec
- Connection blocks for SSH
- Resource dependencies (automatic ordering)
- Automated server configuration
- Shell script execution on remote instances

### New Resource Types
- `aws_key_pair` - Upload SSH public keys to AWS
- `aws_security_group` - Create firewall rules
- Ingress/Egress rules for network traffic

### Provisioner Types
- `file` - Copy files to remote instances
- `remote-exec` - Execute commands on remote instances

## 📁 Files in Main Folder

- `provider.tf` - AWS provider with default_tags
- `main.tf` - EC2 instance, Security Group, Key Pair resources
- `variables.tf` - Variables with validation rules
- `installNginx.sh` - Nginx installation script
- `levelup_key` - SSH private key (RSA 4096-bit)
- `levelup_key.pub` - SSH public key

## 🔧 What I Built

### Infrastructure Components

**1. SSH Key Pair**
```hcl
resource "aws_key_pair" "levelup_key" {
  key_name   = "levelup_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}
```

**2. Security Group**
```hcl
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-server-sg"
  
  ingress {  # SSH - Port 22
    from_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {  # HTTP - Port 80
    from_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {   # All outbound traffic
    from_port   = 0
    protocol    = "-1"
  }
}
```

**3. EC2 Instance with Provisioners**
```hcl
resource "aws_instance" "MyFirstinstance" {
  ami                    = lookup(var.AMIS, var.AWS_REGION)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.levelup_key.key_name
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  
  connection {
    type        = "ssh"
    user        = var.INSTANCE_USERNAME
    private_key = file(var.PATH_TO_PRIVATE_KEY)
    host        = self.public_ip
  }
  
  provisioner "file" {
    source      = "installNginx.sh"
    destination = "/tmp/installNginx.sh"
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/installNginx.sh",
      "sudo sed -i -e 's/\\r$//' /tmp/installNginx.sh",
      "sudo /tmp/installNginx.sh"
    ]
  }
}
```

## 🚀 Commands I Used

### 1. SSH Key Generation
```bash
ssh-keygen -t rsa -b 4096 -f levelup_key -N ""
```
**What this did:**
- Created `levelup_key` (private key, 3381 bytes)
- Created `levelup_key.pub` (public key, 740 bytes)
- Algorithm: RSA, 4096-bit strength
- No passphrase (for automation)

### 2. Terraform Workflow
```bash
terraform init       # Downloaded provider v6.27.0
terraform fmt        # Formatted code
terraform validate   # Validated configuration
terraform plan       # Previewed 3 resources
terraform apply      # Created infrastructure
curl http://<IP>     # Tested nginx
terraform destroy    # Cleaned up
```

## 💡 What I Experienced

### Error 1: Missing SSH Keys
**Initial attempt:**
```bash
terraform plan
```

**Error:**
```
Error: Invalid function argument
no file exists at "levelup_key.pub"
```

**How I fixed:**
```bash
ssh-keygen -t rsa -b 4096 -f levelup_key -N ""
terraform validate  # Success!
```

**What I learned:**
- `file()` function requires file to exist
- SSH keys needed before Terraform can read them
- Generate keys in same directory as .tf files

### Discovery: Connection Block Optimization
**Initial code:** Connection block in EACH provisioner (redundant)

**Optimized to:** Single connection block at resource level

**What I learned:**
- DRY principle (Don't Repeat Yourself)
- Connection at resource level applies to all provisioners
- Cleaner, more maintainable code

## 📊 My Results

### Resources Created
```
1. SSH Key Pair
   - Name: levelup_key
   - Type: RSA
   
2. Security Group  
   - Name: nginx-server-sg
   - ID: sg-xxxxxxxxxxxxxxxxx
   - Rules: SSH (22), HTTP (80), All egress
   
3. EC2 Instance
   - ID: i-xxxxxxxxxxxxxxxxx
   - Public IP: xx.xx.xx.xx
   - Type: t2.micro
   - Nginx: Installed and running ✅
```

### Verification
```bash
curl http://<PUBLIC_IP>
```
**Response:** Nginx welcome page HTML ✅

---

# 📘 Part 2: Data Sources & Remote State

## 🎯 Advanced Topics (data_source/ folder)

See detailed documentation: [data_source/README.md](./data_source/README.md)

### What I Built
- 7 Data sources (AMI, account, region, AZs, VPC, SG, IP ranges)
- EC2 instance using data sources (zero hardcoded values)
- Security group with aws_ip_ranges (50 of 268 IPs)
- Remote state backend (S3)
- Complete outputs for all data sources

### Key Achievements
```
✅ Dynamic AMI lookup (always latest Ubuntu)
✅ AWS IP ranges data source (268 IPs found)
✅ slice() function to limit within AWS quotas
✅ Remote state in S3 (encrypted, versioned)
✅ State migration: local → S3
✅ Zero hardcoded values in entire configuration
```

### Technologies Added
- S3 bucket: `tf-state-learn-001`
- Backend type: `s3`
- Encryption: SSE-S3
- State size: 36KB

---

## 🎓 Complete Skills Gained

### SSH Key Management
```bash
ssh-keygen -t rsa -b 4096 -f levelup_key -N ""
```
**Understanding:**
- `-t rsa` = Algorithm type
- `-b 4096` = Key size (very secure)
- `-f levelup_key` = Output filename
- `-N ""` = No passphrase (automation-friendly)

### Provisioner Workflow
```
Instance created → Wait for boot → SSH connection → 
File provisioner copies script → Remote-exec runs commands → 
Software installed → Server ready!
```

### Data Source Usage
```
Query AWS → Get latest/current data → Use in resources → 
Zero hardcoding → Self-updating infrastructure
```

### Remote State Management
```
Configure backend → terraform init → State migrates to S3 → 
Team-ready → Encrypted → Versioned
```

## 💡 Best Practices I Applied

### Security
- ✅ SSH key-based authentication (no passwords)
- ✅ 4096-bit RSA keys (strong encryption)
- ✅ AWS CLI credentials (no hardcoding)
- ✅ Private keys in .gitignore
- ✅ State file in S3 (encrypted)
- ✅ Removed sensitive data from outputs

### Code Quality
- ✅ Detailed inline comments
- ✅ Formatted with terraform fmt
- ✅ Validated before applying
- ✅ Single connection block (DRY)
- ✅ Separated concerns (securitygroup.tf)

### Production-Ready Patterns
- ✅ Remote state backend
- ✅ Data sources instead of hardcoded values
- ✅ Working within AWS quotas
- ✅ Proper error handling in scripts
- ✅ Resource tagging with metadata

## ⚠️ Important Lessons

### About Provisioners
**HashiCorp warns:** Provisioners are "last resort"

**Why I used them:**
- ✅ Great for learning
- ✅ Understand how configuration works
- ✅ See the full automation flow

**Better alternatives for production:**
- User data (cloud-init)
- Pre-baked AMIs (Packer)
- Configuration management tools (Ansible)

### AWS Quotas
- Security groups: Max 60 rules
- Encountered this limit with aws_ip_ranges
- Used slice() function to work within constraints
- Always check AWS service quotas before designing

### Security Group Configuration
**Current:** Allows SSH/HTTP from anywhere (0.0.0.0/0)
**Production:** Should restrict to specific IPs

## 📈 Complete Achievement

```
Main Project (Provisioners):
- Time: 4-5 hours
- Resources: 3 (Key, SG, Instance)
- Automation: Nginx web server
- Success: ✅ Fully automated deployment

Data Source Project:
- Time: 4-5 hours
- Data sources: 7 types
- Remote state: S3 backend
- Success: ✅ Zero hardcoded values

Total: 8-10 hours of intensive learning
Result: Production-ready Terraform skills
```

## 💪 Combined Skills

### Terraform Mastery
- ✅ Provisioners (file, remote-exec)
- ✅ Data sources (7 types)
- ✅ Remote state (S3 backend)
- ✅ Variables, outputs, functions
- ✅ State management
- ✅ Resource dependencies

### AWS Expertise
- ✅ EC2, Security Groups, Key Pairs
- ✅ VPC, Subnets, Availability Zones
- ✅ AMI management
- ✅ S3 for state storage
- ✅ AWS service quotas

### DevOps Practices
- ✅ Infrastructure as Code
- ✅ Automation
- ✅ Version control ready
- ✅ Security best practices
- ✅ Problem-solving and debugging

---

**Total Time:** 2-3 hours  
**Difficulty:** Intermediate-Advanced  
**Projects:** 2 (Provisioners + Data Sources)  
**Technologies:** Terraform, AWS, S3, Nginx, Bash  
**Status:** ✅ Complete and Production-Ready 🚀
