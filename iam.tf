resource "aws_iam_role" "ssm_instance_role" {
  name = "${var.project_name}-SSMInstanceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.project_name}-SSMInstanceRole"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_instance_role_policy_attachment" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Additional policy for CloudWatch Logs (useful for debugging)
resource "aws_iam_role_policy_attachment" "ssm_instance_cloudwatch_policy" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "${var.project_name}-SSMInstanceProfile"
  role = aws_iam_role.ssm_instance_role.name

  tags = {
    Name = "${var.project_name}-SSMInstanceProfile"
  }
}

# GitHub Actions OIDC Provider (shared across environments)
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    # Official GitHub OIDC thumbprint
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = {
    Name = "GitHub Actions OIDC Provider"
  }
}
