
# Terraform AWS VPC Module

A reusable Terraform module that creates a VPC with public, private and database subnets, route tables, NAT Gateway, Internet Gateway and optional peering to the default VPC.

This README documents what this module implements, the inputs it expects, outputs it exports, data sources and locals used, and usage examples.

## Resources created
Implemented in [vpc.tf](terraform-aws-vpc-module/vpc.tf):
- aws_vpc.vpc_aws
- aws_internet_gateway.main
- aws_subnet.public (count = length(var.public_subnet_cidrs))
- aws_subnet.private (count = length(var.private_subnet_cidrs))
- aws_subnet.database (count = length(var.database_subnet_cidrs))
- aws_route_table.public
- aws_route_table.private
- aws_route_table.database
- aws_route.public (IGW route)
- aws_eip.nat (Elastic IP for NAT)
- aws_nat_gateway.nat (placed in public subnet 0; depends_on IGW)
- aws_route.private (private route pointing to NAT)
- aws_route.database (database route pointing to NAT)
- aws_route_table_association.* (associate each subnet to its route table)

Peering resources (optional), implemented in [peering.tf](terraform-aws-vpc-module/peering.tf):
- aws_vpc_peering_connection.default (count depends on var.is_vpc_peering_required)
- aws_route.public_peering, aws_route.default_peering (route additions to support peering)

Outputs exported in [outputs.tf](terraform-aws-vpc-module/outputs.tf):
- `vpc_id` -> aws_vpc.vpc_aws.id
- `public_subnet_ids` -> aws_subnet.public[*].id
- `private_subnet_ids` -> aws_subnet.private[*].id
- `database_subnet_ids` -> aws_subnet.database[*].id

## Inputs / Module variables
Defined in [variables.tf](terraform-aws-vpc-module/variables.tf). Main inputs:

- [`var.cidr_block`](terraform-aws-vpc-module/variables.tf) (string) — VPC CIDR block.
- [`var.project_name`](terraform-aws-vpc-module/variables.tf) (string) — Project name used in naming/tagging.
- [`var.environment`](terraform-aws-vpc-module/variables.tf) (string) — Environment name used in naming/tagging.
- [`var.vpc_tags`](terraform-aws-vpc-module/variables.tf) (map, default {}) — tags for the VPC.
- [`var.igw_tags`](terraform-aws-vpc-module/variables.tf) (map, default {}) — tags for the Internet Gateway.
- [`var.public_subnet_cidrs`](terraform-aws-vpc-module/variables.tf) (list) — CIDRs for public subnets.
- [`var.public_subnet_tags`](terraform-aws-vpc-module/variables.tf) (map, default {}) — tags for public subnets.
- [`var.private_subnet_cidrs`](terraform-aws-vpc-module/variables.tf) (list) — CIDRs for private subnets.
- [`var.private_subnet_tags`](terraform-aws-vpc-module/variables.tf) (map, default {}) — tags for private subnets.
- [`var.database_subnet_cidrs`](terraform-aws-vpc-module/variables.tf) (list) — CIDRs for database subnets.
- [`var.database_subnet_tags`](terraform-aws-vpc-module/variables.tf) (map, default {}) — tags for database subnets.
- [`var.public_route_table_tags`](terraform-aws-vpc-module/variables.tf) (map, default {}) — tags for public route table.
- [`var.private_route_table_tags`](terraform-aws-vpc-module/variables.tf) (map, default {}) — tags for private route table.
- [`var.database_route_table_tags`](terraform-aws-vpc-module/variables.tf) (map, default {}) — tags for database route table.
- [`var.eip_tags`](terraform-aws-vpc-module/variables.tf) (map, default {}) — tags for Elastic IP used by NAT.
- [`var.nat_gateway_tags`](terraform-aws-vpc-module/variables.tf) (map, default {}) — tags for NAT Gateway.
- [`var.is_vpc_peering_required`](terraform-aws-vpc-module/variables.tf) (bool, default true) — toggle creation of VPC peering and associated routes.

Refer to [variables.tf](terraform-aws-vpc-module/variables.tf) for exact types and default values.

## Data sources and locals
- [data.tf](terraform-aws-vpc-module/data.tf) provides any AWS data sources used by the module (availability zones, remote/default VPC used for peering). See [peering.tf](terraform-aws-vpc-module/peering.tf) for usage of `data.aws_vpc` and `data.aws_route_table`.
- [locals.tf](terraform-aws-vpc-module/locals.tf) defines `local.common_name_suffix`, `local.common_tags`, and `local.az_names` used to construct names and consistent tags across resources.

## Usage example
Example invoking module (see [terraform-aws-vpc-test/main.tf](terraform-aws-vpc-test/main.tf) and [roboshop-dev-infra/00-vpc/main.tf](roboshop-dev-infra/00-vpc/main.tf)):

```hcl
module "vpc" {
  source = "git::https://github.com/arun-t23/terraform-aws-vpc-module.git?ref=main"

  cidr_block            = var.cidr
  project_name          = var.project_name
  environment           = var.environment
  vpc_tags              = var.tags
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  # is_vpc_peering_required = false  # optionally disable peering
}
```

## Behavior notes & implementation details
- NAT Gateway:
  - NAT is created in the first public subnet: `aws_subnet.public[0]` (see [vpc.tf](terraform-aws-vpc-module/vpc.tf)).
  - NAT EIP uses `aws_eip.nat` and NAT gateway resource has `depends_on = [aws_internet_gateway.main]` to ensure IGW exists before NAT creation.
- Routes:
  - Public route table contains a default route to IGW.
  - Private and Database route tables route default traffic (0.0.0.0/0) through the NAT gateway.
- Associations:
  - Each subnet is associated to its respective route table through `aws_route_table_association` resources (counts based on the respective subnet CIDR lists).
- Peering:
  - Peering resources and associated routes are created only when [`var.is_vpc_peering_required`](terraform-aws-vpc-module/variables.tf) is true.
  - Peering uses `data.aws_vpc.default` as the peer; ensure appropriate permissions/availability for the data lookup.

## Outputs
- See [outputs.tf](terraform-aws-vpc-module/outputs.tf) for the exported outputs:
  - `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `database_subnet_ids`.

## Examples and testing
- Reference example invocations:
  - [terraform-aws-vpc-test/main.tf](terraform-aws-vpc-test/main.tf)
  - [roboshop-dev-infra/00-vpc/main.tf](roboshop-dev-infra/00-vpc/main.tf)

## Troubleshooting & tips
- Ensure `public_subnet_cidrs`, `private_subnet_cidrs`, and `database_subnet_cidrs` list lengths align with the expected AZ count in `local.az_names`.
- If peering route creation fails, check `data.aws_vpc.default` and `data.aws_route_table.main` availability in the target account/region.
- Tag maps merge with `local.common_tags` so pass only additional tags required for specific resources.

## License & source
- Module source: https://github.com/arun-t23/terraform-aws-vpc-module (as used in examples)
...existing code...