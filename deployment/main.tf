# Google Storage
//resource "google_storage_bucket" "landing_data" {
//  name          = "${var.host_project_id}-${var.landing_bucket_name}"
//  location      = var.region
//  project       = var.host_project_id
//  force_destroy = "true"
//
//  labels = {
//    logical_functional_zone = "landing"
//    logical_group           = "landing-group"
//    logical_group_types     = "store"
//  }
//}

# Google Compute Engines
resource "google_compute_instance" "vm_instance" {
  name         = var.vm1_name
  machine_type = var.vms_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-1404-trusty-v20190514"
      size  = var.vms_size
    }
  }
  service_account {
    scopes = ["useraccounts-ro", "storage-rw", "logging-write", "bigquery", "compute-rw"]
  }

  allow_stopping_for_update = true

  tags = ["dsactivatortag1", "dsactivatortag2"] 
  network_interface {
   subnetwork = "sb-n-shared-base-europe-west1"
   subnetwork_project = "prj-n-shared-base-d062"
  }
}

