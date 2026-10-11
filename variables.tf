variable "vpc_config" {
  description = "Configuration for the VPC to be created."
  type = object({
    cidr_block = string
    name       = string
  })

  validation {
    condition     = can(cidrnetmask(var.vpc_config.cidr_block))
    error_message = "The cidr_block config option must contain a valid CIDR block."
  }
}

variable "subnet_config" {
  description = "Map of subnets to create, keyed by an arbitrary name. Each entry's cidr_block must be a valid CIDR within the VPC's range, az must be a valid AZ for the region, and public controls whether the subnet gets a route to the internet gateway (default false)."
  type = map(object({
    cidr_block = string
    public     = optional(bool, false)
    az         = string
  }))

  validation {
    condition = alltrue([
      for config in values(var.subnet_config) : can(cidrnetmask(config.cidr_block))
    ])
    error_message = "The cidr_block config option must contain a valid CIDR block."
  }
}