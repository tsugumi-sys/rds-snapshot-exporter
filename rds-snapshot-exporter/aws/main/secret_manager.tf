resource "aws_secretsmanager_secret" "gc_service_account_creds" {
  name = "${var.project_name}-gc-service-account-creds"
}

resource "aws_secretsmanager_secret" "iam-user-creds-for-bq-transfer-api" {
  name = "${var.project_name}-iam-user-creds-for-bq-transfer-api"
}
