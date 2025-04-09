/**
 * OCI FOSS Infrastructure
 * Root module that points to the environments
 */

# IMPORTANT: This file is for guidance only.
# Please navigate to the appropriate environment directory:
# - environments/prod 
# - environments/dev
# And run Terraform commands from there.

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 4.0"
    }
  }
}

# Example of running the prod environment:
# cd environments/prod
# terraform init
# terraform plan -var-file=terraform.tfvars
# terraform apply -var-file=terraform.tfvars 