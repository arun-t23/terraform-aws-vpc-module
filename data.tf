
### getting the data of AZ availaible in the region to pass it to locals.tf or variables.tf
data "aws_availability_zones" "available" {
  state = "available"
}

#### to get the default vpc id so that we can use it in peering

data "aws_vpc" "default" {
  default = true
}

data "aws_route_table" "main" {
  vpc_id  = data.aws_vpc.default.id
  filter {
    name = "association.main"
    values  = ["true"]
  }
}