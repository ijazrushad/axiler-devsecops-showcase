variable "project_id" {
  type        = string
  description = "The GCP project ID to deploy resources into."
}

variable "region" {
  type        = string
  description = "The GCP region to deploy resources into."
  default     = "asia-south1"
}

variable "zone" {
  type        = string
  description = "The GCP zone to deploy resources into."
  default     = "asia-south1-b" 
}

variable "gke_num_nodes" {
  type        = number
  description = "Number of GKE nodes in the default pool."
  default     = 2
}