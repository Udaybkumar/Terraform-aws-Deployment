provider "aws" {
  region = "ap-southeast-1"
}
module "ASG" {
  source = "../Resources/"
}