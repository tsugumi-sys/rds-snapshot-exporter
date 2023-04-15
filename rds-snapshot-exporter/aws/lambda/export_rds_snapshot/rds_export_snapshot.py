import datetime
import logging
import os

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)


class RDSSnapshotExporter:
    def __init__(
        self,
        rds_client,
        rds_instance_identifier: str,
        rds_kms_id: str,
        destination_s3_name: str,
        destination_s3_prefix: str,
        access_s3_role_arn: str,
        max_snapshots: int = 10,
    ):
        self.rds_client = rds_client
        self.rds_instance_identifier = rds_instance_identifier
        self.rds_kms_id = rds_kms_id
        self.destination_s3_name = destination_s3_name
        self.destination_s3_prefix = destination_s3_prefix
        self.access_s3_role_arn = access_s3_role_arn
        self.max_snapshots = max_snapshots

    def export(self):
        snapshot = self._find_latest_snapshot()
        if snapshot is None:
            logger.error("Cannnot Latest Find Snapshot.")
            return

        logger.info("Export Snapshot", snapshot)
        # Use current JST time (str) as task identifier
        current_jst_str = datetime.datetime.now(
            datetime.timezone(datetime.timedelta(hours=9), "JST")
        ).strftime("%Y-%m-%d-%H-%M-%S")
        self._export_snapshot_to_s3(snapshot, f"ExportTaskAt-{current_jst_str}")

    def _find_latest_snapshot(self):
        res = self.rds_client.describe_db_snapshots(
            DBInstanceIdentifier=self.rds_instance_identifier,
            MaxRecords=self.max_snapshots,
            SnapshotType="manual",
        )
        queried_snapshots = res["DBSnapshots"]
        logger.info("Queried Snapshots", queried_snapshots)
        if len(queried_snapshots) == 0:
            return None
        return sort_diclist(queried_snapshots)[0]

    def _export_snapshot_to_s3(self, target_snapshot, task_identifier: str):
        res = self.rds_client.start_export_task(
            ExportTaskIdentifier=task_identifier,
            SourceArn=target_snapshot["DBSnapshotArn"],
            S3BucketName=self.destination_s3_name,
            IamRoleArn=self.access_s3_role_arn,
            KmsKeyId=self.rds_kms_id,
            S3Prefix=self.destination_s3_prefix,
        )
        logger.info("RDS.startExportTask: response: ", res)


def sort_diclist(
    self,
    items: list,  # List of dictionaries.
    sort_key: str = "SnapshotCreateTime",
    ascending=True,
) -> list:
    if len(items) <= 1:
        return items
    return sorted(items, key=lambda x: x[sort_key], reverse=not ascending)


def get_env(env_key: str, default_val=None, raise_err: bool = True):
    value = os.environ.get(env_key, default_val)
    if value is None and raise_err:
        raise ValueError(f"Environment Value [{env_key}] not found in {os.environ}")
    return value


# da
def lambda_handler(event, context):
    rds_instance_identifier = get_env("RDS_INSTANCE_IDENTIFIER")
    rds_kms_id = get_env("RDS_KMS_ID")
    destination_s3_name = get_env("DESTINATION_S3_NAME")
    destination_s3_prefix = get_env("DESTINATION_S3_PREFIX")
    access_s3_role_arn = get_env("ACCESS_S3_ROLE_ARN")
    max_snapshots = int(get_env("MAX_SNAPSHOTS", 20, False))
    exporter = RDSSnapshotExporter(
        boto3.client("rds"),
        rds_instance_identifier,
        rds_kms_id,
        destination_s3_name,
        destination_s3_prefix,
        access_s3_role_arn,
        max_snapshots,
    )
    exporter.export()
