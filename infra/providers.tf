terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "technova-reservas-tfstate-51c9d215"
    key            = "prova/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "technova-reservas-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}