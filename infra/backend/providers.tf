terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  # Sem bloco backend: este projeto usa state LOCAL (ovo e galinha)
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = var.project_name
      Owner     = "Matheus Maciel de Paula"
      RA        = "6325065"
      ManagedBy = "Terraform"
      Purpose   = "terraform-remote-state"
    }
  }
}