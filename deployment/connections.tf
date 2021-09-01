provider "google" {
  project     = var.host_project_id
  region      = var.region
  zone        = var.zone
  credentials = "/var/secrets/google/ec-service-account-config.json"
}

