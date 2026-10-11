# terraform-aws-networking-tf-course
Developed a reusable Terraform networking module as part of the Terraform course, focusing on Infrastructure as Code (IaC) to automate and manage cloud networking resources.  Key Skills: Terraform, AWS VPC, Subnets, Route Tables, Internet Gateway, Security Groups, and Infrastructure as Code (IaC).

Terraform config that builds its own local VPC/subnet module instead of using
a module from the registry, then consumes it from the root configuration.

## How it works

1. **`modules/networking`** is a hand-written local module (see its own
   [README](modules/networking/README.md)) that creates a VPC and any number
   of public/private subnets from a `subnet_config` map, with route
   tables/internet gateway wired up automatically when at least one subnet is
   public.
2. **Root config** (`networking.tf`) calls that module via
   `source = "./modules/networking"`, defining one VPC with 4 subnets across
   4 AZs (2 public, 2 private).
3. **Compute** (`compute.tf`) looks up the latest Ubuntu 22.04 AMI and
   launches a plain `aws_instance` into one of the module's private subnets
   (`module.vpc.private_subnets["subnet_1"].subnet_id`).
4. **Outputs** (`outputs.tf`) re-expose the module's VPC ID and public/private
   subnet maps at the root level.

## Files

| File | Purpose |
|---|---|
| `providers.tf` | Terraform/AWS provider configuration (region `us-east-1`) |
| `networking.tf` | Root call into the local `./modules/networking` module |
| `compute.tf` | Ubuntu AMI lookup + `aws_instance` in a private subnet |
| `outputs.tf` | Re-exports VPC ID and subnet maps from the module |
| `modules/networking/` | The local VPC/subnet module (own README, variables, outputs) |

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Notes

- Subnet keys (`subnet_1`, `subnet_2`, ...) in `subnet_config` are arbitrary
  names you choose — they become the map keys on `module.vpc.public_subnets`
  / `module.vpc.private_subnets`, and are referenced that way elsewhere
  (e.g. `compute.tf`'s `subnet_id`).
- Each subnet's `az` must be a valid, available AZ for the region — the
  module enforces this with a `precondition` and fails with a clear error
  listing valid AZs otherwise.
- A public route table + internet gateway are only created if at least one
  subnet in `subnet_config` has `public = true`.
