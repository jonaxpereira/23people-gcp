resource "google_storage_bucket" "storage_bucket_cloud_sql_init_script" {
  name          = "cloud-sql-init-script"
  location      = "US"
}

resource "google_storage_bucket_object" "init_script" {
  name   = "init-script"
  source = "./init-script.sql"
  bucket = "${google_storage_bucket.storage_bucket_cloud_sql_init_script.name}"
}