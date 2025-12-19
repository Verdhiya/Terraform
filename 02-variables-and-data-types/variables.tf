######################################################
# 1 Part of Variables                               #
######################################################

# variable "AWS_ACCESS_KEY" {}

# variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  default = "us-east-1"
}



# =====================================================================================
# 2 way to mention Variables with command (no need to mention the above vars line)
# =====================================================================================

#  terraform plan -var AWS_ACCESS_KEY="your_access_key" -var AWS_SECRET_KEY="your_secret_key"


# =====================================================
# for SG
# =====================================================

variable "Security_Group" {
  type    = list(any)
  default = ["sg-sv1", "sg-sv2", "sg-sv3"]
}
variable "AMIS" {
  type = map(any)
  default = {
    us-east-1 = "ami-0f40c8f97004632f9"
    us-east-2 = "ami-05692172625678b4e"
    us-west-2 = "ami-0352d5a37fb4f603f"
    us-west-1 = "ami-0f40c8f97004632f9"
  }
}
