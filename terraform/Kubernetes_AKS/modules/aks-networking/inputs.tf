#subnet
variable "snet_name" {}
variable "vnet_name" {}
variable "vnet_rg_name" {}
variable "cidr" {}
variable "vnet_cidr" {}
variable "create_vnet" {
    type = bool
}

#route table
variable "rt_name" {}
variable "rg_location" {}

#Network Security Group
variable "nsg_name" {}



