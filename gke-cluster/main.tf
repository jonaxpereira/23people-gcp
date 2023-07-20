resource "google_service_account" "people_gke_gsa" {
  account_id   = "people-gke-gsa"
  display_name = "people-gke-gsa"
}

resource "google_container_cluster" "people_gke_cluster" {
  name     = "people-gke-cluster"
  location = "us-central1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "people_preemptible_nodes" {
  name       = "people-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.people_gke_cluster.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.people_gke_gsa.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}