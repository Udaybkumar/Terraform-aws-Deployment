variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "is_bucket_enabled" {
  type    = bool
  default = true
}

variable "bucket_name" {
  type    = string
  default = "my-s3-bucket"
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "env" {
  type    = string
  default = "dev"
}
