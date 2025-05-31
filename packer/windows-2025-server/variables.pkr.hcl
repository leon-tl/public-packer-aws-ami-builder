variable "region" {
  default = "ap-southeast-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "share_ami_to_these_accounts" {
  default = ["123456789011", "123456789012", "123456789013"]
}

variable "ami_name" {
  default = "win2025-server-{{isotime `2006-01-02`}}"
}

variable "source_ami_name" {
  default = "Windows_Server-2025-English-Full-Base-*"
}
