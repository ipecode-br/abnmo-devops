resource "aws_lambda_function" "this" {
  function_name    = "${var.project_name}-lambda-${var.environment}"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  filename         = "${path.module}/placeholder.zip"
  source_code_hash = filebase64sha256("${path.module}/placeholder.zip")
  timeout          = var.timeout

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = length(var.private_subnet_ids) > 0 && length(var.security_group_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.private_subnet_ids
      security_group_ids = var.security_group_ids
    }
  }
}

resource "aws_lambda_function_url" "this" {
  function_name      = aws_lambda_function.this.function_name
  authorization_type = var.authorization_type

  # CORS disabled - handled by NestJS application
}