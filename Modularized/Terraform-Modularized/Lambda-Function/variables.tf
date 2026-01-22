variable "functionname" {
  type    = string
  default = "function"
}

variable "lambdafunctionname" {
  type    = string
  default = "lambda-function"
}

variable "lambda-runtime" {
  type    = string
  default = "python3.9"
}

variable "lambda-handler" {
  type    = string
  default = "lambda_function.lambda_handler"
}

variable "handler-code" {
  type    = string
  default = "lambda_function.zip"
}

variable "timout-lambda" {
  type    = number
  default = 30
}

variable "memory-size" {
  type    = number
  default = 128
}

variable "sdlc_env" {
  type    = string
  default = "dev"
}
