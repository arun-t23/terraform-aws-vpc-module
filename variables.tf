variable "cidr_block" {
  type        = string
  description = "Please provide cidr"
}

variable "project_name" {
    type    =   string
}

variable "environment" {
    type    =   string
}


variable "vpc_tags" {
    type    = map
    default = {}
}

variable "igw_tags" {
    type    = map
    default = {}
}

variable "public_subnet_cidrs" {
    type    = list
    description    = "provide subnet cidr"
}

variable "public_subnet_tags" {
    type    = map
    default = {}
}

variable "private_subnet_cidrs" {
    type    = list
    description    = "provide subnet cidr"
}

variable "private_subnet_tags" {
    type    =   map
    default = {}
}
variable "database_subnet_cidrs" {
    type    = list
    description    = "provide subnet cidr"
}

variable "database_subnet_tags" {
    type    =   map
    default = {}
}

variable "public_route_table_tags"{
    type    = map
    default = {}
}

variable "private_route_table_tags"{
    type    = map
    default = {}
}
variable "database_route_table_tags"{
    type    = map
    default = {}
}
variable "eip_tags"{
    type    = map
    default =   {}
}
variable "nat_gateway_tags" {
    type    =   map
    default = {}
}
variable "is_vpc_peering_required" {
    type    = bool
    default = true
}