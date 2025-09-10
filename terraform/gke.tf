
resource "google_container_cluster" "primary" {
  name     = "axiler-gke-cluster"
  location = var.zone

  # Destroy a cluster deletion protection disable
  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  # Enable Workload Identity for secure pod authentication later
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "default-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    machine_type = "e2-medium"
    disk_type    = "pd-standard" 
    disk_size_gb = 30            
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}