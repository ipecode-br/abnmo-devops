# API Gateway REST API
resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "API Gateway for ${var.project_name}-${var.environment}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway Resource (proxy resource to catch all paths)
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

# API Gateway Method (ANY method to handle all HTTP methods)
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

# API Gateway Method for root resource
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_rest_api.this.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

# API Gateway Integration (Lambda proxy integration)
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this.invoke_arn
}

# API Gateway Integration for root resource
resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this.invoke_arn
}

# Lambda permission for API Gateway to invoke the function
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  depends_on = [
    # Lambda integrations
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,

    # OPTIONS methods
    aws_api_gateway_method.options_proxy,
    aws_api_gateway_method.options_root,

    # OPTIONS integrations
    aws_api_gateway_integration.options_proxy,
    aws_api_gateway_integration.options_root,

    # Method responses (CRITICAL)
    aws_api_gateway_method_response.options_proxy,
    aws_api_gateway_method_response.options_root,

    # Integration responses (CRITICAL)
    aws_api_gateway_integration_response.options_proxy,
    aws_api_gateway_integration_response.options_root,
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,

      aws_api_gateway_method.proxy.id,
      aws_api_gateway_method.proxy_root.id,
      aws_api_gateway_method.options_proxy.id,
      aws_api_gateway_method.options_root.id,

      aws_api_gateway_integration.lambda.id,
      aws_api_gateway_integration.lambda_root.id,
      aws_api_gateway_integration.options_proxy.id,
      aws_api_gateway_integration.options_root.id,

      aws_api_gateway_method_response.options_proxy.id,
      aws_api_gateway_method_response.options_root.id,

      aws_api_gateway_integration_response.options_proxy.id,
      aws_api_gateway_integration_response.options_root.id,

      aws_lambda_function.this.source_code_hash,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.environment
}

# API Gateway Custom Domain Name
resource "aws_api_gateway_domain_name" "api" {
  count = var.custom_domain_name != null ? 1 : 0

  domain_name              = var.custom_domain_name
  regional_certificate_arn = var.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-api-domain"
    Environment = var.environment
  }
}

# Base Path Mapping
resource "aws_api_gateway_base_path_mapping" "api" {
  count = var.custom_domain_name != null ? 1 : 0

  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.api[0].domain_name
}


# CORS Configuration for OPTIONS method on proxy resource
resource "aws_api_gateway_method" "options_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# CORS Configuration for OPTIONS method on root resource
resource "aws_api_gateway_method" "options_root" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_rest_api.this.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# CORS Integration for proxy resource
resource "aws_api_gateway_integration" "options_proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options_proxy.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# CORS Integration for root resource
resource "aws_api_gateway_integration" "options_root" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.options_root.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# CORS Method Response for proxy resource
resource "aws_api_gateway_method_response" "options_proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options_proxy.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Credentials" = true
    "method.response.header.Access-Control-Expose-Headers"    = true
    "method.response.header.Access-Control-Max-Age"           = true
  }
}

# CORS Method Response for root resource
resource "aws_api_gateway_method_response" "options_root" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.options_root.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Credentials" = true
    "method.response.header.Access-Control-Expose-Headers"    = true
    "method.response.header.Access-Control-Max-Age"           = true
  }
}

# CORS Integration Response for proxy resource
resource "aws_api_gateway_integration_response" "options_proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options_proxy.http_method
  status_code = aws_api_gateway_method_response.options_proxy.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = "'${join(",", var.cors_allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods"     = "'${join(",", var.cors_allow_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"      = "'${join(",", var.cors_allow_origins)}'"
    "method.response.header.Access-Control-Allow-Credentials" = "'${var.cors_allow_credentials}'"
    "method.response.header.Access-Control-Expose-Headers"    = "'${join(",", var.cors_expose_headers)}'"
    "method.response.header.Access-Control-Max-Age"           = "'${var.cors_max_age}'"
  }
}

# CORS Integration Response for root resource
resource "aws_api_gateway_integration_response" "options_root" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.options_root.http_method
  status_code = aws_api_gateway_method_response.options_root.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = "'${join(",", var.cors_allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods"     = "'${join(",", var.cors_allow_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"      = "'${join(",", var.cors_allow_origins)}'"
    "method.response.header.Access-Control-Allow-Credentials" = "'${var.cors_allow_credentials}'"
    "method.response.header.Access-Control-Expose-Headers"    = "'${join(",", var.cors_expose_headers)}'"
    "method.response.header.Access-Control-Max-Age"           = "'${var.cors_max_age}'"
  }
}
