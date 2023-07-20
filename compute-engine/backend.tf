terraform {
  backend "gcs" {
    bucket = "tfstate-23people"
    prefix = "compute-engine"
  }
}