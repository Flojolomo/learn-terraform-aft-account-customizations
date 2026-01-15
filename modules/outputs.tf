# Outputs
output "deployment_role_arn" {
  value = aws_iam_role.github_actions_deployment.arn
}
