terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
  }

  backend "s3" {
    bucket         = "hello-discord-terraform-state"
    key            = "remote-state"
    region         = "eu-west-2"
    dynamodb_table = "state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region     = "eu-west-2"
  secret_key = ""
  access_key = ""
}