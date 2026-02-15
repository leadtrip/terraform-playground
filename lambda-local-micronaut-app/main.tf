terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}


resource "aws_iam_role" "lambda_role" {
  name = "micronaut_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_lambda_permission" "function_url_public" {
  statement_id  = "AllowPublicAccessFunctionUrl"
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.micronaut_fn.function_name
  principal     = "*"

  function_url_auth_type = "NONE"
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "micronaut_fn" {
  function_name = "micronaut-demo"

  filename         = "app-shadow.jar"
  source_code_hash = filebase64sha256("app-shadow.jar")

  role    = aws_iam_role.lambda_role.arn
  handler = "wood.mike.FunctionRequestHandler"
  runtime = "java21"
}

resource "aws_lambda_function_url" "url" {
  function_name      = aws_lambda_function.micronaut_fn.function_name
  authorization_type = "NONE"
}

output "lambda_url" {
  value = aws_lambda_function_url.url.function_url
}

output "function_name" {
  description = "Name of the Lambda function."
  value = aws_lambda_function.micronaut_fn.function_name
}