locals {
  handler        = "lambda_function.lambda_handler"
  runtime        = "python3.9"
  architectures  = ["x86_64"]
  memory_size_mb = 128
}

resource "aws_lambda_function" "export_rds_snapshot" {
  function_name = "${var.project_name}-export-rds-snapshot"
  filename      = "lambda_function_payload.zip"
  role          = aws_iam_role.role_export_rds_snapshot_task.arn
  handler       = local.handler
  memory_size   = local.memory_size_mb
  architectures = local.architectures
  runtime       = local.runtime
}

resource "aws_lambda_function" "transfer_to_bigquery" {
  function_name = "${var.project_name}-transfer-to-bigquery"
  filename      = "lambda_function_payload.zip"
  role          = aws_iam_role.role_transfer_to_bigquery_task.arn
  handler       = local.handler
  memory_size   = local.memory_size_mb
  architectures = local.architectures
  runtime       = local.runtime
}
