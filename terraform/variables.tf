variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "environment" {
  type    = string
  default = "DevOps-Server"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "instance_type" {
  type    = string
  default = "c7i-flex.large"
}

variable "volume_size" {
  type    = number
  default = 10
}

variable "jenkins_image" {
  type    = string
  default = "jenkins/jenkins:lts" 
}
