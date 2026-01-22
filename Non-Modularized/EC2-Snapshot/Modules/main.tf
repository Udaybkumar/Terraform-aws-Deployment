provider "aws" {
  region = "ap-southeast-1"
}

module "EBS" {
  source = "../Resources/"
}