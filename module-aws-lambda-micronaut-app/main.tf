module "micronaut_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.7.0"

  function_name = "micronaut-demo"

  runtime = "java21"
  handler = "wood.mike.FunctionRequestHandler"

  create_role = true

  create_package = false
  local_existing_package = "../files/mn-shadow-app.jar"

  create_lambda_function_url = true
  authorization_type         = "NONE"
}

output "lambda_url" {
  value = module.micronaut_lambda.lambda_function_url
}