resource "google_service_account" "service_account_gce" {
  account_id   = "gce-gsa"
  display_name = "gce-gsa"
}

resource "google_project_iam_binding" "service_account_gce_binding" {
  project = "people-393416"
  role    = "roles/container.admin"
  members = ["serviceAccount:${google_service_account.service_account_gce.email}"]
}

resource "google_compute_instance" "compute_instance_bastion" {
  name         = "bastion"
  machine_type = "n2-standard-8"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = <<-EOF1
      #! /bin/bash
      echo "Hello, World!" > /tmp/hello.txt
      sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
      sudo apt-get install kubectl
      sudo gcloud container clusters get-credentials people-gke-cluster --region us-central1 --project people-393416
    EOF1

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.service_account_gce.email
    scopes = ["cloud-platform"]
  }
}