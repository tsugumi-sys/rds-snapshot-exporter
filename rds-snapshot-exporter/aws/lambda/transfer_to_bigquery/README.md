## AWS Lambda: Transfer RDS snapshot to bigquery.

1. Retrieve exported tables names of RDS from s3 bucket.
2. Create BigQuery table if not exists.
3. Post transfer requests for each tables.


### Environment variables

Set the following environment variables of aws lambda.
- `GC_PROJECT_ID` (required) : Target Google Cloud project id.
- `BIGQUERY_DATASET_ID` (required) : Target BigQuery dataset id.
- `AWS_SECRET_NAME_FOR_GC_SERVICE_ACCOUNT` (required) : Name of AWS Secret that stores Google Cloud service account credentials.
- `AWS_SECRET_NAME_FOR_IAM_USER` (required) : Name of AWS Secret that stores access keys of IAM user for bigquery transfer api python client.
- `AWS_SECRET_REGION` (required) : Name of target AWS region.
- `SOUCE_S3_BUCKET_NAME` (required) : Name of s3 bucket name that contain RDS snapshot data.
- `EXPORT_TASK_NAME` (required) : Name of RDS export task name. The task name is defined in `../export_rds_snapshot/lambda_function.py`,
and also RDS snapshot data is exported to S3 where the prefix name is the same as the export task name.
