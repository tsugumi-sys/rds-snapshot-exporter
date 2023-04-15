resource "google_bigquery_dataset" "dataset" {
  depends_on = [google_service_account.bq_admin]
  dataset_id = "rds_data"
  location   = var.project_region

  access {
    role          = "roles/bigquery.admin"
    user_by_email = google_service_account.bq_admin.email
  }
}
