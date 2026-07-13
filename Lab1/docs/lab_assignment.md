# Coursework: Upgrading to Multi-Region Load Balancing
**Module 1: Advanced GCP Architectures — Highly Available & Latency-Optimized Topologies**

## Objective
In this assignment, you will upgrade your baseline single-region HR Vacation Request subsystem into a highly available, latency-optimized Multi-Regional topology. You will deploy a second frontend instance in Europe, configure Anycast routing via the Global Load Balancer, and set up cross-region Cloud SQL Postgres replication with Cloud DNS abstraction.

---

## Assignment Tasks

### Step 1: Declare a Second Regional Cloud Run Frontend Service
In `terraform/main.tf`, declare a new regional Cloud Run frontend service in a second region (e.g., `europe-west1`):

```hcl
resource "google_cloud_run_v2_service" "frontend_europe" {
  name     = "hr-vacation-frontend-europe"
  location = "europe-west1"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.app_repo.repository_id}/frontend:latest"
      ports {
        container_port = 8080
      }
      env {
        name  = "BACKEND_API_URL"
        value = google_cloud_run_v2_service.backend_service.uri
      }
    }
  }
}
```

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> In `terraform/main.tf`, declare a new Google Cloud Run v2 service named `frontend_europe` (service name "hr-vacation-frontend-europe") in region `europe-west1`. It should use the same container configuration, image registry repository, and env variables as `google_cloud_run_v2_service.frontend_service` but set the ingress property to INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER.
> ```

---

### Step 2: Create a European Serverless NEG
Define a regional serverless Network Endpoint Group (NEG) targeting the new European Cloud Run frontend service:

```hcl
resource "google_compute_region_network_endpoint_group" "serverless_neg_europe" {
  name                  = "hr-vacation-neg-europe"
  network_endpoint_type = "SERVERLESS"
  region                = "europe-west1"
  cloud_run {
    service = google_cloud_run_v2_service.frontend_europe.name
  }
}
```

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> Write a Terraform resource block for a regional serverless network endpoint group named `serverless_neg_europe` (NEG name "hr-vacation-neg-europe") in `europe-west1`. Configure it to target the new Cloud Run service `google_cloud_run_v2_service.frontend_europe`.
> ```

---

### Step 3: Register Both Regional NEGs to the Backend Service
Update the existing Load Balancer backend service (`google_compute_backend_service.backend_service`) in `main.tf` to route traffic to both the US and Europe NEGs. GCLB will automatically direct clients to the nearest region using Anycast IP routing:

```hcl
resource "google_compute_backend_service" "backend_service" {
  name                  = "hr-vacation-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  # Primary US Backend NEG
  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }

  # Failover / Latency-Optimized Europe Backend NEG
  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg_europe.id
  }
}
```

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> Update the `google_compute_backend_service.backend_service` resource in `terraform/main.tf` by adding a second `backend` block that references the new European serverless NEG ID: `google_compute_region_network_endpoint_group.serverless_neg_europe.id`.
> ```

---

### Step 4: Configure Cross-Region Cloud SQL Replication & Private DNS
To ensure low-latency reads in Europe and high availability, configure a Cloud SQL Read Replica in `europe-west1`.

1. **Declare the Cloud SQL Read Replica** in `main.tf`:
   ```hcl
   resource "google_sql_database_instance" "postgres_replica" {
     name                 = "hr-vacation-sql-db-replica"
     database_version     = "POSTGRES_15"
     region               = "europe-west1"
     master_instance_name = google_sql_database_instance.postgres.name

     settings {
       tier = "db-f1-micro"
       ip_configuration {
         ipv4_enabled    = false
         private_network = google_compute_network.vpc_network.id
       }
     }
   }
   ```

2. **Map Private DNS Records** inside Cloud DNS to provide database host abstractions:
   ```hcl
   # Map DB_WRITE_HOST: write-db.hr-vacation.internal -> Primary Cloud SQL Private IP
   resource "google_dns_record_set" "write_dns" {
     name         = "write-db.hr-vacation.internal."
     managed_zone = google_dns_managed_zone.private_zone.name
     type         = "A"
     ttl          = 60
     rrdatas      = [google_sql_database_instance.postgres.private_ip_address]
   }

   # Map DB_READ_HOST: read-db.hr-vacation.internal -> Replica Cloud SQL Private IP
   resource "google_dns_record_set" "read_dns" {
     name         = "read-db.hr-vacation.internal."
     managed_zone = google_dns_managed_zone.private_zone.name
     type         = "A"
     ttl          = 60
     rrdatas      = [google_sql_database_instance.postgres_replica.private_ip_address]
   }
   ```

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> Please write the Terraform configurations for cross-region replication:
> 1. Add a `google_sql_database_instance` named `postgres_replica` in `europe-west1` linked as a replica to `google_sql_database_instance.postgres`. Enable private IP and set tier to db-f1-micro.
> 2. Add two `google_dns_record_set` resources named `write_dns` and `read_dns` under the private Cloud DNS zone mapping "write-db.hr-vacation.internal." and "read-db.hr-vacation.internal." to the private IP address of the primary and replica Cloud SQL instances respectively.
> ```

---

## Verification & Failover Test
Once applied:
1. Access the web portal via the DNS address: `https://hr-vacation.gcp-lab.internal`.
2. Inspect the Live Traffic Visualizer diagram to confirm the addition of the European region.
3. Simulate a database failover by promoting the Cloud SQL replica in `europe-west1` and updating the Cloud DNS record for `write-db.hr-vacation.internal.` to point to the promoted instance.
