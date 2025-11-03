#### Terraform AWS VPC module

This Module creates the following resources
* VPC
* Internet Gateway
* 2 public subnets in us-east-1a and us-east-1b
* 2 private subnets in us-east-1a and us-east-1b
* 2 Database subnets in us-east-1a and us-east-1b
* Route tables for Public, Private and Database
* Elastic IP for NAT Gateway
* NAT Gateway in public subnet 1a AZ
* IGW route is added to public route table
* NAT GAteway to Private and Database route tables
* Route table association with subnets
* VPC to default VPC peering
* Public route table to default VPC route
* Default VPC main route table to created VPC routw


