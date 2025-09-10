# Custom VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "axiler-vpc"
  auto_create_subnetworks = false
}

# Subnet within the VPC
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}