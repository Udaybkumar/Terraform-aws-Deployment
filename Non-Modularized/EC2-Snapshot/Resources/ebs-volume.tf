resource "aws_ebs_volume" "volume" {
  availability_zone = "ap-southeast-1a"
  size              = 30
}