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

data "google_client_config" "current" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.people_gke_cluster.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.people_gke_cluster.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
}
resource "google_compute_address" "default" {
  name   = "lb7-gke-ip"
  region = "us-central1"
}
resource "kubernetes_service" "nginx" {
  metadata {
    namespace = kubernetes_namespace.staging.metadata[0].name
    name      = "nginx"
  }
  spec {
    selector = {
      run = "nginx"
    }
    session_affinity = "ClientIP"
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
    type             = "LoadBalancer"
    load_balancer_ip = google_compute_address.default.address
  }
}
resource "kubernetes_replication_controller" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.staging.metadata[0].name
    labels = {
      run = "nginx"
    }
  }
  spec {
    selector = {
      run = "nginx"
    }
    template {
      metadata {
        labels = {
          run = "nginx"
        }
      }
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"
        }
      }
    }
  }
}
output "load-balancer-ip" {
  value = google_compute_address.default.address
}