locals {
  snapshot_bucket_arn = aws_s3_bucket.snapshot_bucket.arn
  kms_key_arn         = aws_kms_key.kms_key.arn
}

###
# IAM User for BigQuery Transfer API client.
resource "aws_iam_user" "iam_user" {
  name = "${var.project_name}-iam-user-for-bq-transfer-api"
}

resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.iam_user.name
  policy_arn = aws_iam_policy.bq_tranasfer_api_policy.arn
}

resource "aws_iam_policy" "bq_tranasfer_api_policy" {
  name   = "${var.project_name}-bq-transfer-policy"
  policy = data.aws_iam_policy_document.bq_transfer_api_policy.json
}

data "aws_iam_policy_document" "bq_transfer_api_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:List*", "s3:Get*"]
    resources = ["${local.snapshot_bucket_arn}/*", local.snapshot_bucket_arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [local.kms_key_arn]
  }
}

###
# IAM Role for Export RDS Snapshot Lambda Execution.
###
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role_export_rds_snapshot_task" {
  name               = "${var.project_name}-export-rds-snapshot-task"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "export_rds_snapshot_task" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "rds:DescribeDBSnapshots",
      "rds:StartExportTask",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy_export_rds_snapshot_task" {
  name   = "${var.project_name}-export-rds-snapshot-task"
  path   = "/"
  policy = data.aws_iam_policy_document.export_rds_snapshot_task.json
}

resource "aws_iam_role_policy_attachment" "attach_export_rds_snapshot_task" {
  role       = aws_iam_role.role_export_rds_snapshot_task.name
  policy_arn = aws_iam_policy.policy_export_rds_snapshot_task.arn
}
###
# IAM Role for BigQuery Transfer Lambda Execution.
###
resource "aws_iam_role" "role_transfer_to_bigquery_task" {
  name               = "${var.project_name}-transfer-to-bigquery-task"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

###
# Lambda logging
###
resource "aws_iam_role_policy_attachment" "attach_lambda_logging_export" {
  role       = aws_iam_role.role_export_rds_snapshot_task.name
  policy_arn = aws_iam_policy.policy_lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "attach_lambda_logging_BQ_transfer" {
  role       = aws_iam_role.role_transfer_to_bigquery_task.name
  policy_arn = aws_iam_policy.policy_lambda_logging.arn
}

resource "aws_iam_policy" "policy_lambda_logging" {
  name   = "${var.project_name}-lambda-logging"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_logging.json
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}
