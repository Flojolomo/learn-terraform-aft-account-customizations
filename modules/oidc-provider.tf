# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

# GitHub Actions Deployment Role
resource "aws_iam_role" "github_actions_deployment" {
  name                 = "GitHubActions-${var.github_org}-${var.github_repository}-DeploymentRole"
  description          = "Role for GitHub Actions to deploy Time Tracking application"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:${var.github_repository}:ref:refs/heads/main",
            "repo:${var.github_repository}:pull_request",
            "repo:${var.github_repository}:environment:production",
            "repo:${var.github_repository}:environment:development"
          ]
        }
      }
    }]
  })
}

# PowerUserAccess covers S3, CloudFormation, CloudFront, SSM, etc.
resource "aws_iam_role_policy_attachment" "power_user" {
  role       = aws_iam_role.github_actions_deployment.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Only IAM permissions needed (not included in PowerUserAccess)
resource "aws_iam_role_policy" "iam_permissions" {
  name = "IAMPermissions"
  role = aws_iam_role.github_actions_deployment.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:*"
      ]
      Resource = "*"
    }]
  })
}




