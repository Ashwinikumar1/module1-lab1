# Coursework: Upgrading to Multi-Region Load Balancing
**Module 1 - Phase 1: High Availability, Global Routing & Latency Optimization**

## Objective
To support low-latency global transactions for subsidiaries in Europe and Asia, students must upgrade the baseline single-region configuration into a highly available, multi-regional topology.

Follow these step-by-step instructions to update your application code and IaC templates to be multi-regional:

---

## Step-by-Step Assignment Instructions

### Step 1: Declare a Second Regional Cloud Run App Service
In `terraform/main.tf`, declare a new regional Cloud Run app service in a second region (e.g., `europe-west1`):

```hcl
resource "google_cloud_run_v2_service" "app_europe" {
  name     = "hr-vacation-app-europe"
  location = "europe-west1"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app_repo.repository_id}/app:latest"
      ports {
        container_port = 8080
      }
      env {
        name  = "DB_WRITE_HOST"
        value = "write-db.hr-vacation.internal"
      }
      env {
        name  = "DB_READ_HOST"
        value = "read-db.hr-vacation.internal"
      }
      env {
        name  = "DB_PASS"
        value = random_password.alloydb_password.result
      }
    }
    # Enforce routing outbound traffic through Serverless VPC Connector
    vpc_access {
      connector = google_vpc_access_connector.vpc_connector.id
      egress    = "ALL_TRAFFIC"
    }
  }
}
```

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> In terraform/main.tf, declare a new Google Cloud Run v2 service named `app_europe` (service name "hr-vacation-app-europe") in region `europe-west1`. Configure container image pointing to Artifact Registry, ingress property set to INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER, environment variables DB_WRITE_HOST and DB_READ_HOST pointing to private DNS hostnames, and outbound traffic routed through the Serverless VPC Connector.
> ```

---

### Step 2: Create a European Serverless NEG
Define a regional serverless Network Endpoint Group (NEG) targeting the new European Cloud Run app service:

```hcl
resource "google_compute_region_network_endpoint_group" "serverless_neg_europe" {
  name                  = "hr-vacation-neg-europe"
  network_endpoint_type = "SERVERLESS"
  region                = "europe-west1"
  cloud_run {
    service = google_cloud_run_v2_service.app_europe.name
  }
}
```

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> Write a Terraform resource block for a regional serverless network endpoint group named `serverless_neg_europe` (NEG name "hr-vacation-neg-europe") in `europe-west1`. Target the new Cloud Run app service `google_cloud_run_v2_service.app_europe`.
> ```

---

### Step 3: Register Both Regional NEGs to the Backend Service
Update the existing backend service (`google_compute_backend_service.backend_service`) to route traffic to both the US and Europe NEGs. GCLB will automatically direct clients to the nearest region using Anycast IP routing:

```hcl
resource "google_compute_backend_service" "backend_service" {
  name                  = "hr-vacation-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  # Primary US Backend
  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }

  # Failover / Latency-Optimized Europe Backend
  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg_europe.id
  }
}
```

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> Update `google_compute_backend_service.backend_service` in `terraform/main.tf` by adding a second `backend` block referencing the European serverless NEG ID: `google_compute_region_network_endpoint_group.serverless_neg_europe.id`.
> ```

---

### Step 4: Configure Cross-Region AlloyDB Replication & Private DNS
To ensure highly available relational transactions and seamless regional failovers, configure an AlloyDB Primary cluster in `us-central1` and an asynchronous Secondary replica cluster in `europe-west1` with Continuous Storage-level log streaming. Declare the Secondary cluster and instance in Terraform:

```hcl
# AlloyDB Secondary DR Cluster in europe-west1
resource "google_alloydb_cluster" "secondary" {
  cluster_id   = "hr-vacation-cluster-secondary"
  location     = "europe-west1"
  cluster_type = "SECONDARY"

  network_config {
    network = google_compute_network.vpc_network.id
  }

  secondary_config {
    primary_cluster_name = google_alloydb_cluster.primary.name
  }

  deletion_protection = false
}

# Secondary replica instance in europe-west1
resource "google_alloydb_instance" "secondary_instance" {
  cluster       = google_alloydb_cluster.secondary.name
  instance_id   = "hr-vacation-secondary-instance"
  instance_type = "SECONDARY"

  machine_config {
    cpu_count = 2
  }

  depends_on = [google_alloydb_instance.primary_instance]
}
```

And map private DNS records inside Cloud DNS to provide abstraction endpoints:

```hcl
# Map DB_WRITE_HOST: write-db.hr-vacation.internal -> Primary AlloyDB IP
resource "google_dns_record_set" "write_dns" {
  name         = "write-db.hr-vacation.internal."
  managed_zone = google_dns_managed_zone.private_zone.name
  type         = "A"
  ttl          = 60
  rrdatas      = [google_alloydb_instance.primary_instance.ip_address]
}
```

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> Write the Terraform configurations for cross-region replication and DNS abstraction:
> 1. Add `google_alloydb_cluster.secondary` in `europe-west1` as a SECONDARY cluster pointing to the primary cluster name.
> 2. Add `google_alloydb_instance.secondary_instance` in `europe-west1` depends_on the primary instance.
> 3. Add `google_dns_record_set.write_dns` mapping "write-db.hr-vacation.internal." to the private IP of the primary database instance.
> ```

---

### Step 5: Verify the Multi-Regional Setup & Failover
1. Apply the updated Terraform configuration (`terraform apply`).
2. Verify that GCLB forwards traffic to both `us-central1` and `europe-west1` based on user location.
3. Access the portal and inspect the simulated terminal logs. Confirm that requests are routed securely to the nearest database node!
4. Practice a simulated disaster recovery failover by promoting the Secondary AlloyDB cluster in `europe-west1` and redirecting Cloud DNS `write-db.hr-vacation.internal.` record to point to the promoted instance without redeploying the backend.

---

## 📊 Summary Scoring Matrix

| Step | Task Objective | Points |
|---|---|---|
| **Step 1** | Declare European Cloud Run App Service (`app_europe`) | 20 Points |
| **Step 2** | Create European Serverless NEG (`serverless_neg_europe`) | 20 Points |
| **Step 3** | Register both NEGs to GCLB Backend Service | 20 Points |
| **Step 4** | Configure Secondary AlloyDB Cluster & Private DNS Record | 20 Points |
| **Step 5** | Verify Anycast Routing & DR Failover Promotion | 20 Points |
