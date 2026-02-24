terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

############################
# VARIABLES + VALIDATION
############################

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"

  validation {
    condition     = can(regex("^eu-", var.aws_region))
    error_message = "Only EU regions are allowed for this example."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "instance_names" {
  description = "Logical instance names"
  type        = list(string)
  default     = ["api", "worker"]
}

variable "allowed_ports" {
  description = "Inbound ports to allow"
  type        = set(number)
  default     = [22, 8080]
}

############################
# LOCALS (EXPRESSIONS)
############################

locals {
  # Conditional expression
  instance_type = var.environment == "prod" ? "t3.micro" : "t2.micro"

  # String interpolation + functions
  name_prefix = "${var.environment}-demo"

  # Map created from list (for_each friendly)
  instances = {
    for name in var.instance_names :
    name => "${local.name_prefix}-${name}"
  }

  # Derived list
  ssh_only = length(var.allowed_ports) == 1 && contains(var.allowed_ports, 22)
}

############################
# DATA SOURCE
############################

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

############################
# SECURITY GROUP (ITERATION)
############################

resource "aws_security_group" "app_sg" {
  name        = "${local.name_prefix}-sg"
  description = "Learning SG with dynamic rules"

  # dynamic allows nestable, repeatable blocks
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# EC2 INSTANCES (for_each)
############################

resource "aws_instance" "app" {
  for_each = local.instances

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name        = each.value
    Environment = var.environment
  }
}

############################
# OUTPUTS (FOR EXPRESSIONS)
############################

output "instance_ids" {
  description = "EC2 instance IDs"
  value = {
    for name, instance in aws_instance.app :
    name => instance.id
  }
}

output "instance_private_ips" {
  description = "Private IPs as a list"
  value       = [for i in aws_instance.app : i.private_ip]
}

output "ssh_hint" {
  description = "Helpful message based on expressions"
  value = local.ssh_only
    ? "Only SSH is exposed"
    : "Multiple ports are exposed"
}