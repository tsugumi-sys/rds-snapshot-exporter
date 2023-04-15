
###
# Lambda
###
resource "aws_cloudwatch_log_group" "export_rds_snapshot_task" {
  name              = "/aws/lambda/${aws_lambda_function.export_rds_snapshot.function_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "transfer_to_bigquer" {
  name              = "/aws/lambda/${aws_lambda_function.transfer_to_bigquery.function_name}"
  retention_in_days = 30
}
