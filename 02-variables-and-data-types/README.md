# 02 - Variables and Data Types

## 📚 What I Learned in This Lesson

### Variable Concepts
- Variable declaration syntax
- Different variable types (string, list, map)
- Variable usage with `var.` prefix
- Map lookups for dynamic values
- Variable defaults and overrides
- terraform.tfvars for value assignment

### Data Types Mastered
- **String** - Single text values (regions, names)
- **List** - Multiple values in array (security groups)
- **Map** - Key-value pairs (regional AMI mappings)

## 📁 Files I Created

- `provider.tf` - AWS provider configuration
- `main.tf` - EC2 instance using variables
- `variables.tf` - Variable declarations
- `terraform.tfvars` - Variable values (optional)

## 🔧 What I Built

### Variables Implemented

**String Variable:**
```hcl
variable "AWS_REGION" {
  default = "us-east-1"
}
```

**List Variable:**
```hcl
variable "Security_Group" {
  type = list
  default = ["sg-sv1", "sg-sv2", "sg-sv3"]
}
```

**Map Variable:**
```hcl
variable "AMIS" {
  type = map
  default = {
    us-east-1 = "ami-0f40c8f97004632f9"
    us-east-2 = "ami-05692172625678b4e"
    us-west-2 = "ami-0352d5a37fb4f603f"
    us-west-1 = "ami-0f40c8f97004632f9"
  }
}
```

### Using Variables in Resources
```hcl
resource "aws_instance" "MyFirstInstance" {
  ami             = var.AMIS[var.AWS_REGION]  # Map lookup
  instance_type   = "t2.micro"
  security_groups = var.Security_Group        # List variable
}
```

## 🚀 Commands I Used

### Initialization
```bash
terraform init        # Downloaded providers (AWS + Azure)
terraform fmt         # Formatted all .tf files
terraform validate    # Validated configuration
```

### Testing Variables
```bash
# Plan with default values
terraform plan

# Override region (test map lookup)
terraform plan -var="AWS_REGION=us-west-2"

# Override to different region
terraform plan -var="AWS_REGION=us-east-2"
```

### Exploring Variables with Console
```bash
terraform console

# Commands I tested:
> var.AMIS
> var.AMIS["us-east-1"]
> var.AMIS[var.AWS_REGION]
> var.Security_Group
> exit
```

## 💡 What I Experienced

### Testing Map Lookups

**Test 1: us-west-2**
```bash
terraform plan -var="AWS_REGION=us-west-2"
```
**Result:** AMI changed to `ami-0352d5a37fb4f603f` automatically! ✅

**Test 2: us-east-2**
```bash
terraform plan -var="AWS_REGION=us-east-2"
```
**Result:** AMI changed to `ami-05692172625678b4e` automatically! ✅

**Key Discovery:** Map lookups work dynamically - same code, different regions!

### Terraform Console Exploration
```
> var.AMIS
tomap({
  "us-east-1" = "ami-0f40c8f97004632f9"
  "us-east-2" = "ami-05692172625678b4e"
  "us-west-1" = "ami-0f40c8f97004632f9"
  "us-west-2" = "ami-0352d5a37fb4f603f"
})

> var.AMIS[var.AWS_REGION]
"ami-0f40c8f97004632f9"

> var.Security_Group
tolist([
  "sg-sv1",
  "sg-sv2",
  "sg-sv3",
])
```

## 🐛 Errors I Encountered & Fixed

### Error 1: Map Type Mismatch
**What I did wrong:**
```hcl
ami = var.AMIS  # ❌ Gave entire map to string attribute
```

**Error message:**
```
Error: Incorrect attribute value type
Inappropriate value for attribute "ami": string required, but have map of dynamic.
```

**How I fixed it:**
```hcl
ami = var.AMIS[var.AWS_REGION]  # ✅ Map lookup returns string
```

**What I learned:**
- Map variable contains multiple values
- Need to lookup specific key to get single value
- Terraform validates attribute types

### Error 2: Understanding References
**My question:** Will Terraform create security groups with names sg-sv1, sg-sv2, sg-sv3?

**Answer I learned:**
- ❌ NO - Variables are REFERENCES, not creation instructions
- Security groups must exist or be created explicitly
- `security_groups = [...]` looks for existing SGs
- To create: use `resource "aws_security_group"`

## 📖 Key Concepts Mastered

### Variable Declaration
```hcl
variable "name" {
  type        = type
  description = "What it is"
  default     = value
}
```

### Variable Reference
```hcl
var.variable_name  # Access variable value
```

### Map Lookup Syntax
```hcl
var.AMIS[var.AWS_REGION]           # Direct lookup
lookup(var.AMIS, var.AWS_REGION)   # Function lookup (safer)
```

### List Usage
```hcl
security_groups = var.Security_Group  # Entire list
```

## 🎓 Skills I Gained

### Variable Operations
- ✅ Declare variables with type constraints
- ✅ Set default values
- ✅ Use maps for regional configurations
- ✅ Perform map lookups
- ✅ Reference lists in resources
- ✅ Override variables via command line
- ✅ Test variables in terraform console

### Dynamic Configuration
- ✅ Same code works across multiple regions
- ✅ AMI selection based on region
- ✅ Reusable infrastructure code
- ✅ DRY principle applied

### Debugging Skills
- ✅ Read Terraform error messages
- ✅ Understand type mismatches
- ✅ Use console for testing
- ✅ Fix errors independently

## 💪 Commands That Became Essential

### terraform console
**What I used it for:**
- Testing variable values
- Checking map lookups
- Verifying list contents
- Experimenting with expressions

**Examples:**
```bash
terraform console
> var.AMIS                    # View entire map
> var.AMIS["us-east-1"]       # Test specific key
> var.AMIS[var.AWS_REGION]    # Test dynamic lookup
> length(var.Security_Group)  # Count list items
```

### terraform plan with -var
**What I discovered:**
- Can override any variable from command line
- Highest priority (overrides defaults and tfvars)
- Great for testing different scenarios
- No code changes needed

## 📊 What I Created

### Variable Types Used
```
String Variables: 1 (AWS_REGION)
List Variables: 1 (Security_Group)
Map Variables: 1 (AMIS with 4 regions)
Total Variables: 3
```

### Testing Results
```
terraform plan (default)         → Uses us-east-1 AMI
terraform plan -var us-west-2    → Uses us-west-2 AMI ✅
terraform plan -var us-east-2    → Uses us-east-2 AMI ✅
```

## 💡 Best Practices I Learned

### Variable Naming
- Use descriptive names (AWS_REGION not reg)
- UPPER_CASE for constants-like variables
- Consistent naming across files

### Type Safety
- Always specify `type` for variables
- Prevents accidental wrong type assignments
- Makes errors clearer

### Defaults
- Provide defaults for optional values
- No defaults for required values (forces user input)
- Empty defaults (`""` or `[]`) to avoid prompts

### Organization
- All variables in variables.tf
- All values in terraform.tfvars
- Separate concerns

## ⚠️ Important Lessons

### Map vs Direct Assignment
```hcl
# Wrong ❌
ami = var.AMIS  # Gives entire map

# Right ✅
ami = var.AMIS[var.AWS_REGION]  # Gives single AMI string
```

### Lists are References
```hcl
security_groups = var.Security_Group  # References existing SGs
# Does NOT create them if they don't exist!
```

### Variable Precedence
```
Command line -var     (highest)
terraform.tfvars
Environment variables
Default in variable
Interactive prompt    (lowest)
```

---

**Time Spent:** 2-3 hours  
**Difficulty:** Intermediate  
**Concepts Mastered:** Variables, Maps, Lists, Lookups  
**Errors Fixed:** 2  
**Console Sessions:** Multiple  
**Success Rate:** 100% after debugging 💪

