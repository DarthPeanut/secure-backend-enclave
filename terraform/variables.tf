variable "resource_group_name" {
    type = string
    default = "secure-enclave-rg"
    description = "The core rg for the architecture"
}

variable "location" {
    type = string
    default = "eastus2"
    description = "The location for the resources"
}

variable "environment" {
    type = string
    default = "dev"
    description = "The environment for the resources"
}

variable "enable strict_isolation" {
    type = bool
    default = false
    description = "Toggle TRUE for cleared environments (VNETS, WAF, Private Links)"
}