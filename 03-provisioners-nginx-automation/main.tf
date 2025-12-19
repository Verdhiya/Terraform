# ============================================
# EC2 Instance with Nginx Installation
# Modern approach with proper security group
# ============================================

# SSH Key Pair Resource
resource "aws_key_pair" "levelup_key" {     # 1. Create SSH key pair in AWS
  key_name   = "levelup_key"                # 2. Key name in AWS
  public_key = file(var.PATH_TO_PUBLIC_KEY) # 3. Read public key from file
}

# Security Group for Nginx
resource "aws_security_group" "nginx_sg" {   # 4. Create security group
  name        = "nginx-server-sg"            # 5. Security group name
  description = "Allow SSH and HTTP traffic" # 6. Description

  # SSH Access
  ingress { # 7. Inbound rule for SSH
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 8. Allow from anywhere (change to your IP in production)
  }

  # HTTP Access
  ingress { # 9. Inbound rule for HTTP
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Traffic
  egress { # 10. Outbound rule
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-server-sg"
  }
}

# EC2 Instance
resource "aws_instance" "MyFirstinstance" {                  # 11. Create EC2 instance
  ami                    = lookup(var.AMIS, var.AWS_REGION)  # 12. Map lookup for AMI
  instance_type          = "t2.micro"                        # 13. Instance type
  key_name               = aws_key_pair.levelup_key.key_name # 14. Reference SSH key
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]  # 15. Reference security group

  tags = { # 16. Instance tags
    Name = "nginx-server"
  }

  # ✅ Single connection block for all provisioners
  connection {
    type        = "ssh"
    user        = var.INSTANCE_USERNAME
    private_key = file(var.PATH_TO_PRIVATE_KEY)
    host        = self.public_ip
  }

  # Copy script to instance
  provisioner "file" {                   # 17. File provisioner
    source      = "installNginx.sh"      # 18. Local script file
    destination = "/tmp/installNginx.sh" # 19. Remote destination
  }

  # Execute installation script
  provisioner "remote-exec" {                           # 25. Remote execution provisioner
    inline = [                                          # 26. Commands to execute
      "chmod +x /tmp/installNginx.sh",                  # 27. Make script executable
      "sudo sed -i -e 's/\\r$//' /tmp/installNginx.sh", # 28. Remove Windows line endings
      "sudo /tmp/installNginx.sh"                       # 29. Execute script
    ]
  }
}
