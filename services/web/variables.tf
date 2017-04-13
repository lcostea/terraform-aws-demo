#set the values with your own variables from vpc creation
variable "vpc_id" {
  default = "vpc-ecee6384"
}

variable "subnet_id" {
  default     = "subnet-24a93c5e"
  description = "Public"
}

variable "public_key_path" {
  default = "F:/Presentations/Terraform-Ansible_AWS/terraform-demo-eu-central.pem"
}
