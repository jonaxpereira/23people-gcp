resource "google_artifact_registry_repository" "people_repository" {
  location      = "us-central1"
  repository_id = "people-repository"
  description   = "docker repository"
  format        = "DOCKER"
}