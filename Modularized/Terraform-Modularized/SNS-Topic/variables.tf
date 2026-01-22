variable "is_enable" {
  type    = bool
  default = true
}

variable "topic_name" {
  type    = string
  default = "my-sns-topic"
}

variable "is_subscription_enable" {
  type    = bool
  default = true
}

variable "protocol_subscription" {
  type    = string
  default = "email"
}

variable "endpoint" {
  type    = string
  default = "example@example.com"
}
