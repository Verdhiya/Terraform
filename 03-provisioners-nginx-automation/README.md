# 03 - Provisioners & Nginx Automation

## 📚 What I Learned in This Lesson

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

## 📁 Files I Created

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

### 2. Terraform Initialization
```bash
terraform init
```
**Result:**
- Downloaded AWS provider v6.27.0 (using ~> 6.0 constraint)
- Created .terraform/ directory
- Created .terraform.lock.hcl

### 3. Code Formatting
```bash
terraform fmt
```
**Files formatted:**
- 01-instance.tf
- 02-provider.tf
- 03-variables.tf

### 4. Validation
```bash
terraform validate
```
**Output:** Success! The configuration is valid.

### 5. Planning
```bash
terraform plan
```
**What I saw:**
- Plan: 3 to add (key pair + security group + instance)
- All resource details shown
- Security group rules displayed

### 6. Deployment
```bash
terraform apply
```
**Typed:** yes

### 7. Testing Web Server
```bash
curl http://<PUBLIC_IP>
```
**Result:** Nginx welcome page HTML returned ✅

### 8. Cleanup
```bash
terraform destroy
```
**Typed:** yes

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

### Understanding: Security Groups
**My question:** Can I use existing security group instead of creating new one?

**Answer I learned:**
- ✅ Yes, use `data "aws_security_group"` to reference existing
- Current approach (creating new) gives full control
- Good for learning and self-contained projects

**My question:** Why connection block twice?

**Answer I learned:**
- One connection block is enough at resource level
- Each provisioner can have its own (for different connections)
- Same connection = define once

### Understanding: Default Values
**My question:** With `default = ""`, will Terraform prompt me?

**Answer I learned:**
- ❌ NO - empty string is still a default value
- Terraform only prompts when NO default exists
- `default = ""` vs no default at all

**My question:** Does `default = []` read from AWS?

**Answer I learned:**
- ❌ NO - it's just an empty list
- Does NOT query AWS for existing resources
- To read from AWS, use data sources

## 📊 My Results

### Resources Created
```
1. SSH Key Pair
   - Name: levelup_key
   - Type: RSA
   - Fingerprint: xx:xx:xx:...
   
2. Security Group  
   - Name: nginx-server-sg
   - ID: sg-xxxxxxxxxxxxxxxxx
   - Rules: SSH (22), HTTP (80), All egress
   
3. EC2 Instance
   - ID: i-xxxxxxxxxxxxxxxxx
   - Public IP: xx.xx.xx.xx
   - Private IP: 172.31.x.x
   - Type: t2.micro
   - Nginx: Installed and running ✅
```

### Deployment Timeline
```
00:00s - terraform apply started
00:00s - aws_key_pair created (instant)
00:03s - aws_security_group created
00:13s - aws_instance created
00:20s - SSH connection established
00:20s - file provisioner: uploaded installNginx.sh
00:20s - remote-exec provisioner started
01:00s - Cloud-init wait completed
01:10s - apt-get update (17.7 MB downloaded)
01:20s - nginx installation (13 packages)
01:26s - ✅ Nginx running successfully!
```

### Verification
```bash
curl http://<PUBLIC_IP>
```
**Response:** Nginx welcome page HTML ✅

### Destruction Timeline
```
00:00s - terraform destroy started
00:20s - aws_instance destroyed
00:20s - aws_key_pair destroyed (instant)
00:21s - aws_security_group destroyed
00:21s - ✅ All resources destroyed
```

## 🎓 Skills I Gained

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
Instance created
    ↓
Wait for boot
    ↓
SSH connection established
    ↓
File provisioner copies script
    ↓
Remote-exec runs commands
    ↓
Software installed
    ↓
Server ready!
```

### Resource Dependencies
**Learned:** Terraform automatically orders resources
```
aws_key_pair (no dependencies)
    ↓
aws_security_group (no dependencies)  
    ↓
aws_instance (depends on both above)
```

## 💡 Best Practices I Applied

### Security
- ✅ SSH key-based authentication (no passwords)
- ✅ 4096-bit RSA keys (strong encryption)
- ✅ AWS CLI credentials (no hardcoding)
- ✅ Private keys in .gitignore

### Code Quality
- ✅ Detailed inline comments
- ✅ Formatted with terraform fmt
- ✅ Validated before applying
- ✅ Single connection block (DRY)

### Provisioner Script
- ✅ Wait for cloud-init to complete
- ✅ Error handling (`set -e`)
- ✅ Progress messages
- ✅ Service verification
- ✅ Auto-detection of public IP in script

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

### Security Group Configuration
**Current:** Allows SSH/HTTP from anywhere (0.0.0.0/0)
**Production:** Should restrict to specific IPs

### Connection Block Position
**Learned:** Put at resource level, not in each provisioner
- More efficient
- Easier to maintain
- Follows DRY principle

## 🧪 What I Tested

### 1. Web Server Access
```bash
curl http://<PUBLIC_IP>
```
**Result:** Received nginx HTML ✅

### 2. SSH Connection (Manual)
```bash
ssh -i levelup_key ubuntu@<PUBLIC_IP>
systemctl status nginx  # Verified running
exit
```

### 3. State Inspection
```bash
terraform show              # Viewed all resources
terraform state list        # Listed 3 resources
```

## 📈 My Achievement

```
Started: Basic Terraform knowledge
Ended: Can deploy automated web servers

Skills progression:
- Manual infrastructure → Automated with code
- Hardcoded values → Dynamic variables
- Static deployments → Automated provisioning

Time invested: 4-5 hours
Infrastructure created: 3 AWS resources
Web server: Fully functional nginx
Automation level: 100%
```

## 💪 What I Can Do Now

- ✅ Generate and manage SSH keys
- ✅ Create security groups programmatically
- ✅ Upload files to remote instances
- ✅ Execute commands on remote servers
- ✅ Automate software installation
- ✅ Deploy working web applications
- ✅ Manage complete infrastructure lifecycle
- ✅ Debug provisioner issues
- ✅ Understand when to use/avoid provisioners

## 🔗 What's Next

After mastering this:
- **Next:** 04-

---

**Time Spent:** 4-5 hours  
**Difficulty:** Intermediate-Advanced  
**Resources Created:** 3 (Key Pair, Security Group, EC2)  
**Provisioners Used:** 2 (file, remote-exec)  
**Web Server Status:** ✅ Successfully deployed and verified  
**Final Status:** ✅ Destroyed cleanly  
**Real-World Skill Level:** Production-ready provisioning 🚀
