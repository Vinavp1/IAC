provider "aws" {
  region     = "ap-south-1"
}
data "archive_file" "zip_the_python_code" {
 type        = "zip"
 source_dir  = "D:/GitHub/Cradlewise/python/"
 output_path = "D:/GitHub/Cradlewise/python/hellopy.zip"
}

resource "aws_lambda_function" "credlewise_lambda_func" {
 filename                       = "D:/GitHub/Cradlewise/python/hellopy.zip"
 function_name                  = "Credlewise-Lambda-Function"
 role                           = "arn:aws:iam::339712734289:role/terraform_aws_lambda_role"
 handler                        = "hellopy.lambda_handler"
 runtime                        = "python3.8"
}

output "teraform_logging_arn_output" {
 value = aws_lambda_function.credlewise_lambda_func.arn
}

resource "aws_api_gateway_rest_api" "test_api" {
  name        = "testapi"
  description = "Example API Gateway"
}

resource "aws_api_gateway_resource" "gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  parent_id   = aws_api_gateway_rest_api.test_api.root_resource_id
  path_part   = "test"
}

resource "aws_api_gateway_method" "gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.test_api.id
  resource_id   = aws_api_gateway_resource.gateway_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "gatway_integration" {
  rest_api_id             = aws_api_gateway_rest_api.test_api.id
  resource_id             = aws_api_gateway_resource.gateway_resource.id
  http_method             = aws_api_gateway_method.gateway_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.credlewise_lambda_func.invoke_arn
}

resource "aws_api_gateway_deployment" "gatewat_deployment" {
  depends_on    = [aws_api_gateway_integration.gatway_integration]
  rest_api_id   = aws_api_gateway_rest_api.test_api.id
  stage_name    = "prod"
}

output "api_gateway_base_url" {
  value = aws_api_gateway_deployment.gatewat_deployment.invoke_url
}