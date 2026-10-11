# terraform-aws-networking-tf-course

A reusable Terraform module that creates a VPC and any number of
public/private subnets from a simple config map, with route tables and an
internet gateway wired up automatically when at least one subnet is public.

Developed as part of a Terraform course to practice building and publishing
a module to the Terraform Registry.

## Usage

```hcl
module "vpc" {
  source  = "devops-avinashsain/networking-tf-course/aws"
  version = "~> 0.2"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "example-vpc"
  }

  subnet_config = {
    subnet_1 = {
      cidr_block = "10.0.0.0/24"
      az         = "us-east-1a"
    }
    subnet_2 = {
      cidr_block = "10.0.1.0/24"
      # Public subnets are indicated by setting the "public" option to true.
      public = true
      az     = "us-east-1b"
    }
  }
}
```

See [`examples/complete`](examples/complete) for a full example.

## Inputs

| Name | Description | Type |
|---|---|---|
| `vpc_config` | `cidr_block` and `name` for the VPC | `object({ cidr_block = string, name = string })` |
| `subnet_config` | Map of subnets to create, keyed by an arbitrary name. Each entry's `cidr_block` must be a valid CIDR within the VPC's range, `az` must be a valid AZ for the region, and `public` controls whether the subnet gets a route to the internet gateway (default `false`) | `map(object({ cidr_block = string, public = optional(bool, false), az = string }))` |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | The AWS ID of the created VPC |
| `public_subnets` | Map of public subnets: key => `{ subnet_id, availability_zone }` |
| `private_subnets` | Map of private subnets: key => `{ subnet_id, availability_zone }` |

## Notes

- A subnet's `az` must be a valid, available AZ for the region — invalid AZs
  fail with a clear error listing the valid options for the region.
- A public route table and internet gateway are only created if at least one
  subnet in `subnet_config` has `public = true`.
