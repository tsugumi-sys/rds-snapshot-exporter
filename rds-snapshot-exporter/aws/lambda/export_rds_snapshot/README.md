## AWS Lambda: Export RDS Snapshot to S3

Posting `RDS.startExportTask` request to target RDS instance.

### Environment variables

Set the following environment variables of aws lambda.

- `RDS_INSTANCE_IDENTIFIER` (required) : Target RDS instance.
- `RDS_KMS_ID` (required) : KMS ID to use with exporting task. You cannnot use defualt rds kms and need to create custom KMS.
- `DESTINATION_S3_NAME` (required) : Destination S3 bucket name.
- `ACCESS_S3_ROLE_ARN` (required) : IAM role to allow `boto3.RDS` client accessgin the destination bucket.
- `MAX_SNAPSHOTS` (optional): Default is 20. Max number of snapshots to search.
- `DESTINATION_S3_PREFIX` (optional): Default is "". Prefix of the destination bucket.
