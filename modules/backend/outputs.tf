############
## Lambda ##
############
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "lambda_function_url" {
  description = "URL of the Lambda function"
  value       = aws_lambda_function_url.this.function_url
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.this.invoke_arn
}

#################
## API Gateway ##
#################
output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.this.id
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "api_gateway_stage_name" {
  description = "Stage name of the API Gateway deployment"
  value       = aws_api_gateway_stage.this.stage_name
}

###################
## Custom Domain ##
###################
output "custom_domain_name" {
  description = "Custom domain name for the API Gateway"
  value       = var.custom_domain_name != null ? aws_api_gateway_domain_name.api[0].domain_name : null
}

output "custom_domain_target" {
  description = "Target domain name for CNAME record"
  value       = var.custom_domain_name != null ? aws_api_gateway_domain_name.api[0].regional_domain_name : null
}

#########
## SNS ##
#########
output "sns_topic_arn" {
  description = "ARN do tópico SNS de alertas de budget"
  value       = aws_sns_topic.budget_alerts.arn
}