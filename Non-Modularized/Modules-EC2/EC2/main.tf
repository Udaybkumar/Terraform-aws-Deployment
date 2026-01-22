provider "aws" {
  region = "ap-southeast-1"

module "Instance-Creation" {
  source = "../EC2/"
}