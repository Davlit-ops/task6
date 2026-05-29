variable "region" {
  type    = string
  default = "us-east-2"
}

variable "project_name" {
  type    = string
  default = "task6"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "domain_name" {
  type = string
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnets" {
  description = "Map of subnets for the VPC"
  type = map(object({
    cidr = string
    az   = string
  }))
}
