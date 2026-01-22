variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "is_enable_vpc" {
  type    = bool
  default = true
}

variable "cidr_block_vpc" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instance_tenancy_vpc" {
  type    = string
  default = "default"
}

variable "dns" {
  type    = bool
  default = true
}

variable "name_vpc" {
  type    = string
  default = "modularized-vpc"
}

variable "is_enable_ig" {
  type    = bool
  default = true
}

variable "gateway_name" {
  type    = string
  default = "modularized-igw"
}

variable "is_subnet_enable_public" {
  type    = bool
  default = true
}

variable "public_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "az1" {
  type    = string
  default = "ap-southeast-1a"
}

variable "map_public_ip" {
  type    = bool
  default = true
}

variable "public_subnet" {
  type    = string
  default = "public-subnet"
}

variable "is_subnet_enable_private" {
  type    = bool
  default = true
}

variable "private_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "az2" {
  type    = string
  default = "ap-southeast-1b"
}

variable "map_private_ip" {
  type    = bool
  default = false
}

variable "private_subnet" {
  type    = string
  default = "private-subnet"
}

variable "is_enable_rt" {
  type    = bool
  default = true
}

variable "route_public" {
  type    = string
  default = "0.0.0.0/0"
}

variable "rt_name" {
  type    = string
  default = "public-route-table"
}

variable "is_enable_rta" {
  type    = bool
  default = true
}

variable "is_sg_enable" {
  type    = bool
  default = true
}

variable "from_port1" {
  type    = number
  default = 80
}

variable "to_port1" {
  type    = number
  default = 80
}

variable "from_port2" {
  type    = number
  default = 443
}

variable "to_port2" {
  type    = number
  default = 443
}

variable "sg_name" {
  type    = string
  default = "modularized-sg"
}
