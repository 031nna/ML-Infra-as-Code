# Default values



variable "admin_user" {
  description = "Nizzles mail"
}

variable "droplet_image" {
  description = "Image identifier of the OS in DigitalOcean"
  default     = "ubuntu-20-04-x64"
}

variable "aws_profile" {
  description = "AWS profile to use"
  default     = "aws_david_dev"
}


# NB: For 30,000 users/day use the equivalent of s-4vcpu-8gb 
# or betterstill split into two servers (s-2vcpu-4gb x 2)  https://slugs.do-api.dev/




variable "instance_count" {
    description = "number of running droplets"
    type = number
    default = 1 #2
}

variable "db_instance_count" {
    description = "number of running droplets"
    type = number
    default = 0
}

variable "app_domain_name" {
    description = "name of app domain"
    default = "03i.co"
}

variable "records" {
  type = list(object({
    value    = string
    priority = number
  }))

  default = [
    {
      value    = "ASPMX.L.GOOGLE.COM."
      priority = 1
    },
    {
      value    = "ALT1.ASPMX.L.GOOGLE.COM."
      priority = 5
    },
    {
      value    = "ALT2.ASPMX.L.GOOGLE.COM."
      priority = 5
    },
    {
      value    = "ALT3.ASPMX.L.GOOGLE.COM."
      priority = 10
    },
    {
      value    = "ALT4.ASPMX.L.GOOGLE.COM."
      priority = 10
    }
  ]
}

variable "aws_region" {
  description = "ec2 instance type"
  type = string
  default = "us-east-1"
}

variable "ami_id" {
    description = "ami image type eg ubuntu"
    type = string
    default = "ami-067cf009aedb2612d"  #"ami-0fc5d935ebf8bc3bc" # "t4g.small"  
}

variable "instance_type" {
    description = "instance type"
    type = string
    default = "t4g.small" #"t3.micro" #  "ami-067cf009aedb2612d" 
}

variable "private_key_path" {
  description = "The file path to the private SSH key used to access servers(EC2 instances/DO droplets)"
  type        = string
  default     = "~/.ssh/id_rsa" # Replace with the path to your private key
}

variable "aws_key_name" {
  description = "The name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = "giggl-staging" # "03i-staging". Replace with your actual key pair name in AWS
}

variable "ebs_volume_size" {
  default = 20  # Set the new size (adjust as needed)
}
 