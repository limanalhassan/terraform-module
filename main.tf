provider "aws" {
  region = "us-west-1"
}

data "aws_availability_zones" "azs" {}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.cidr_block
}

module "s3" {
  source = "./modules/s3"
  
}