# Default values
variable "instance_type" {
  description = "Image identifier of the OS "
  default     = "ml.t2.medium" 
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

variable "aws_region" {
  description = "ec2 instance type"
  type = string
  default = "us-east-1"
}

variable "private_key_path" {
  description = "The file path to the private SSH key used to access servers(EC2 instances/DO droplets)"
  type        = string
  default     = "~/.ssh/id_rsa" # Replace with the path to your private key
}
 
 
 