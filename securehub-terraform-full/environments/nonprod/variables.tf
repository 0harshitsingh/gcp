variable "project_id" {}
variable "region" { default = "asia-south1" }

variable "hub_network_name" { default = "securehub-vpc" }
variable "hub_subnet_name" { default = "securehub-subnet-asia" }
variable "hub_subnet_cidr" { default = "10.236.0.0/20" }

variable "spoke_network_name" { default = "app-spoke-vpc" }
variable "spoke_subnet_name" { default = "app-spoke-subnet" }
variable "spoke_subnet_cidr" { default = "10.240.0.0/24" }
