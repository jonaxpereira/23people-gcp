terraform {
  backend "gcs" {
    bucket = "tfstate-23people"
    prefix = "cloud-dns"
  }
}