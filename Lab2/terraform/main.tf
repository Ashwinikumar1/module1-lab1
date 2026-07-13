# Provider Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Variables
variable "gcp_project_id" {
  description = "The GCP Project ID"
  type        = string
  default     = "alpha-code-461805"
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "us-east1"
}

variable "environment" {
  description = "Environment identifier"
  type        = string
  default     = "prd"
}

# 1. VPC and Subnets (AWS VPC & Subnet equivalent)
resource "google_compute_network" "vpc_network" {
  name                    = "adserver1-${var.environment}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_a" {
  name          = "adserver1-${var.environment}-subnet-a"
  ip_cidr_range = "10.17.0.0/19"
  region        = var.gcp_region
  network       = google_compute_network.vpc_network.id

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.18.0.0/16"
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "172.20.0.0/16"
  }
}

resource "google_compute_subnetwork" "subnet_b" {
  name          = "adserver1-${var.environment}-subnet-b"
  ip_cidr_range = "10.17.32.0/19"
  region        = var.gcp_region
  network       = google_compute_network.vpc_network.id
}

# 2. Cloud KMS Key Ring and Key (AWS KMS Key & Alias equivalent)
resource "google_kms_key_ring" "kms_key_ring" {
  name     = "adserver1-${var.environment}-keyring"
  location = var.gcp_region
}

resource "google_kms_crypto_key" "gke_kms_key" {
  name            = "adserver1-${var.environment}-gke-key"
  key_ring        = google_kms_key_ring.kms_key_ring.id
  rotation_period = "31536000s" # 365 days
}

data "google_project" "project" {}

resource "google_kms_crypto_key_iam_member" "gke_kms_iam" {
  crypto_key_id = google_kms_crypto_key.gke_kms_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "gcs_kms_iam" {
  crypto_key_id = google_kms_crypto_key.gke_kms_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

# 3. Service Account for GKE Worker Nodes (AWS IAM Role equivalent)
resource "google_service_account" "gke_node_sa" {
  account_id   = "adserver1-${var.environment}-node-sa"
  display_name = "Service Account for GKE Node Pool"
}

resource "google_project_iam_member" "node_sa_roles" {
  for_each = toset([
    "roles/container.nodeServiceAccount",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader"
  ])
  project = var.gcp_project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}

# 4. GKE Cluster (AWS EKS Cluster equivalent)
resource "google_container_cluster" "gke_cluster" {
  name                = "adserver1-${var.environment}"
  location            = var.gcp_region
  deletion_protection = false

  # Separate node pool management
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.subnet_a.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  node_config {
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.gke_kms_key.id
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  release_channel {
    channel = "REGULAR"
  }

  depends_on = [google_kms_crypto_key_iam_member.gke_kms_iam]
}

# 5. GKE Node Pool (AWS EKS Node Group equivalent)
resource "google_container_node_pool" "main_node_pool" {
  name       = "prd-adserver1-prd-main"
  location   = var.gcp_region
  cluster    = google_container_cluster.gke_cluster.name
  node_count = 3

  autoscaling {
    min_node_count = 1
    max_node_count = 6
  }

  node_config {
    machine_type = "c2-standard-4" # Optimized equivalent for compute-heavy AWS c5.large
    disk_size_gb = 200
    disk_type    = "pd-standard"

    service_account = google_service_account.gke_node_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    labels = {
      "Cluster"              = "adserver1-prd"
      "NodeGroup"            = "main"
      "ex.co/is_primary"     = "true"
      "Environment"          = var.environment
    }

    tags = ["gke-node", "adserver1-prd-node"]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# 6. Cloud Storage Bucket and Policy (AWS S3 Bucket equivalent)
resource "google_storage_bucket" "deployment_bucket" {
  name                     = "ad-server-frequency-cappi-deployment-${var.gcp_project_id}"
  location                 = var.gcp_region
  force_destroy            = false
  public_access_prevention = "enforced"

  uniform_bucket_level_access = true

  encryption {
    default_kms_key_name = google_kms_crypto_key.gke_kms_key.id
  }

  labels = {
    stage       = "production"
    environment = var.environment
  }

  depends_on = [google_kms_crypto_key_iam_member.gcs_kms_iam]
}

# Outputs
output "gke_cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "gke_cluster_endpoint" {
  value     = google_container_cluster.gke_cluster.endpoint
  sensitive = true
}

output "vpc_network_name" {
  value = google_compute_network.vpc_network.name
}

output "deployment_bucket_url" {
  value = google_storage_bucket.deployment_bucket.url
}
