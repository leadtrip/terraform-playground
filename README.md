Test groud for playing around with terraform.

## Main commands
* init - Prepare your working directory for other commands
* validate - Check whether the configuration is valid
* plan - Show changes required by the current configuration
* apply - Create or update infrastructure
* destroy - Destroy previously-created infrastructure

## Blocks overview
* terraform  → tool config
* provider   → which cloud + how to connect
* resource   → create something
* data       → look up something
* variable   → input parameter
* locals     → internal helper values
* output     → print/export values
* module     → reuse code
* backend    → where state lives

## Blocks detail
### terraform
Defines Terraform-level settings and required providers
```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.6"
}
```
### provider
Configures how Terraform talks to a platform (AWS, Azure, etc.)
```terraform
provider "aws" {
  region = "eu-west-2"
}
```
### resource
Creates or manages infrastructure, resources are detailed [here](https://registry.terraform.io/providers/hashicorp/aws/latest)
```terraform
resource "TYPE" "NAME" {
    argument = value
}
```
### data
Fetches existing infrastructure, does not create it
```terraform
data "TYPE" "NAME" {
  filter = ...
}
```
### variable
Declares configurable inputs
```terraform
variable "region" {
  type    = string
  default = "eu-west-2"
}
```
### output
Exports values after apply
```terraform
output "bucket_name" {
  value = aws_s3_bucket.logs.bucket
}
```
### locals
Defines reusable expressions inside config
```terraform
locals {
  common_tags = {
    Project = "demo"
  }
}
```
### module
Calls another terraform package
```terraform
module "network" {
  source = "./modules/vpc"

  cidr = "10.0.0.0/16"
}
```
### backend
Configures where Terraform state lives
```terraform
terraform {
  backend "s3" {
    bucket = "tf-state"
    key    = "app.tfstate"
    region = "eu-west-2"
  }
}
```
## Sample projects in this repo
### js-lambda-api-gateway
Creates an S3 bucket, builds the app, deploys the app to the S3 bucket, creates a lambda that sources the app from the S3 bucket and creates an API gateway
Once applied, you can execute the following commands to check the s3 bucket, execute the lambda directly and through the API gateway
```
aws s3 ls $(terraform output -raw lambda_bucket_name)
aws lambda invoke --region=us-east-1 --function-name=$(terraform output -raw function_name) response.json
cat response.json
curl "$(terraform output -raw base_url)/hello"
curl "$(terraform output -raw base_url)/hello?Name=Terraform"
```
## lambda-local-micronaut-app
Packages a jar micronaut app and deploys to lambda\
Execute the lambda and check response with the following.
```
aws lambda invoke --region=eu-west-2 --function-name=$(terraform output -raw function_name) response.json
cat response.json
```