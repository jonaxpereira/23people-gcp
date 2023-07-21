resource "google_service_account" "people_gke_gsa" {
  account_id   = "people-gke-gsa"
  display_name = "people-gke-gsa"
}

resource "google_project_iam_binding" "project" {
  project = "people-393416"
  role    = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:${google_service_account.people_gke_gsa.email}",
  ]
}

resource "google_container_cluster" "people_gke_cluster" {
  name     = "people-gke-cluster"
  location = "us-central1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # enable workload identity
  workload_identity_config {
    workload_pool = "people-393416.svc.id.goog"
  }
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
    oauth_scopes = [
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

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.people_gke_cluster.endpoint}"
    cluster_ca_certificate = base64decode(google_container_cluster.people_gke_cluster.master_auth.0.cluster_ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
}

resource "google_compute_address" "default" {
  name   = "lb7-gke-ip"
  region = "us-central1"
}

resource "helm_release" "helm_release_ingress_nginx" {
  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.5.2"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = google_compute_address.default.address
  }
}

resource "google_service_account" "gsa_heroes" {
  account_id = "heroes-gsa"
}

resource "google_project_iam_binding" "tf_gsa_binding" {
  project = "people-393416"
  role    = "roles/cloudsql.client"

  members = [
    "serviceAccount:${google_service_account.gsa_heroes.email}",
  ]
}

resource "kubernetes_service_account" "ksa_heroes" {
  metadata {
    name = "ksa-heroes"
    annotations = {
      "iam.gke.io/gcp-service-account" = "${google_service_account.gsa_heroes.email}",
    }
  }
}

resource "google_service_account_iam_binding" "workload_identity_role_heroes" {
  service_account_id = google_service_account.gsa_heroes.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:people-393416.svc.id.goog[default/ksa-heroes]"
  ]
}

resource "kubernetes_secret" "secret-gcp-key" {

  metadata {
    name      = "gcpkey"
    namespace = "default"
    labels = {
      "sensitive" = "true"
    }
  }
  data = {
    "key.json" = file("../key.json")
  }
}

resource "kubernetes_service" "heroes" {
  metadata {
    namespace = "default"
    name      = "heroes"
  }
  spec {
    selector = {
      run = "heroes"
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }
    type = "NodePort"
  }
}

resource "kubernetes_deployment_v1" "example" {
  metadata {
    name = "heroes"
    labels = {
      run = "heroes"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        run = "heroes"
      }
    }

    template {
      metadata {
        labels = {
          run = "heroes"
        }
      }

      spec {
        service_account_name = "ksa-heroes"
        container {
          name  = "heroes"
          image = "us-central1-docker.pkg.dev/people-393416/people-repository/heroes:1.0.7"
        }

        # sidecar proxy auth cloud sql
        container {
          name  = "cloud-sql-proxy"
          image = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.1.0"
          args = [ 
            "--structured-logs",
            "--port=5432",
            "people-393416:us-central1:main-instance",
            "--credentials-file=/secrets/key.json"
          ]
          security_context {
            run_as_non_root = true
          }
          volume_mount {
            name = "gcpkey-volume"
            mount_path = "/secrets/"
            read_only = true
          }
        }
        
        volume {
          name = "gcpkey-volume"
          secret {
            secret_name = "gcpkey"
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "23people-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "heroes"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "google_dns_managed_zone" "dns_jonaxpereira" {
  name     = "jonaxpereira-dns-zone"
  dns_name = "jonaxpereira.com."
}

resource "google_dns_record_set" "a" {
  name         = google_dns_managed_zone.dns_jonaxpereira.dns_name
  managed_zone = google_dns_managed_zone.dns_jonaxpereira.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_address.default.address]
}

