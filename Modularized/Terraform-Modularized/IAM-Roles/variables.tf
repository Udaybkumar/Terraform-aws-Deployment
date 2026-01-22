variable "policy_name" {
  type    = string
  default = "iam-policy"
}

variable "policy_file" {
  type    = string
  default = "policy.json"
}

variable "role_name" {
  type    = string
  default = "iam-role"
}

variable "role_policy_file" {
  type    = string
  default = "role-policy.json"
}
