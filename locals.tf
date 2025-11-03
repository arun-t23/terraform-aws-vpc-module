locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    terraform   = true
  }
  common_name_suffix = "${var.project_name}-${var.environment}" ### we get roboshop-dev
  az_names  =   slice(data.aws_availability_zones.available.names, 0, 2) #### used from data.tf fro az zones selection
}


