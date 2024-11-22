terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
  }
}

provider "aws" {
  region     = "eu-west-2"
  secret_key = ""
  access_key = ""
}