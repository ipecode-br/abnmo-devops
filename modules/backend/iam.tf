resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}_${var.environment}_lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# GitHub Actions role to deploy Lambda functions
resource "aws_iam_role" "abnmo_svm_github_oidc_lambda_deploy" {
  name = "abnmo-svm-github-actions-lambda-deploy-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.github_oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        },
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:ipecode-br/abnmo-backend:ref:refs/heads/*"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_deploy_policy" {
  name        = "lambda-deploy-permissions-${var.environment}"
  description = "Allows GitHub to update Lambda functions via OIDC for ${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:GetFunctionConfiguration",
          "lambda:UpdateFunctionConfiguration"
        ],
        Resource = aws_lambda_function.this.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_deploy_policy" {
  role       = aws_iam_role.abnmo_svm_github_oidc_lambda_deploy.name
  policy_arn = aws_iam_policy.lambda_deploy_policy.arn
}

output "github_oidc_deploy_role_arn" {
  value = aws_iam_role.abnmo_svm_github_oidc_lambda_deploy.arn
}