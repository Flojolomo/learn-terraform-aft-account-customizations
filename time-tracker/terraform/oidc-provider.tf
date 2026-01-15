module "oidc_provider" {
  source = "../../modules"

  github_org        = "Flojolomo"
  github_repository = "time-tracking-app"
}

output "oidc_role_arn" {
  description = "ARN to be assumed by GitHub Actions"
  value       = module.oidc_provider.deployment_role_arn
}
