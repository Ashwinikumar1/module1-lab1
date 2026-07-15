# Lab 1 Student Lab Guide: Modernizing GCP Workloads via Agentic Tools
**Module 1 - Phase 1**

---

## 📌 Overview & Metadata

* **Lab Title**: Module 1 - Phase 1: Modernizing GCP Workloads via Agentic Tools
* **Lab Type**: **Learning lab (build)** — Guided step-by-step scenario focused on structured learning and foundational skill building.
* **Intended Learner Profile**: Candidate for Practice CE, Platform CE (incl. PA), Outcome CE, and GCC Engineers.

> ⚠️ **STRICT PRODUCTION DISCIPLINE & ZERO-CONSOLE POLICY**: You are operating in a restricted production governance environment. **Direct manual web interaction with the Google Cloud Console (`console.cloud.google.com`) is strictly disabled.** You MUST use Agentic AI tools (VS Code Antigravity Extension, Antigravity CLI, Antigravity 2.0, Google Agent Skills, and `gcloud` via terminal/MCP) for all infrastructure discovery, log reading, refactoring, code updates, declarative IaC execution, imperative CLI tool calls, and health verifications.

---

## 📝 Lab Summary

This lab validates your ability to transition smoothly between application engineering and production operations on Google Cloud. You use agentic IDEs, such as the **VS Code Antigravity Plugin**, **Antigravity 2.0**, the **Antigravity CLI**, and the **Google Cloud CLI**. You architect, build, and deploy core infrastructure using **Google Agent Skills** and the **Model Context Protocol (MCP)**.

In this lab, you analyze an existing Google Cloud application (`ce-sample-hr-vacation`). You use agentic tools to discover information about the workload, which includes building an architecture diagram. You then review feedback from a customer meeting to identify deficiencies in the existing application. The existing HR vacation request application operates on a simplified, single-region infrastructure.

The customer notes state that this application has scalability and availability limitations. You address these limitations in this lab.

A single Virtual Private Cloud (VPC) subnetwork in one geographic region contains the entire application. The application uses the following core Google Cloud services:

* **Cloud Run (Frontend)**: This service acts as the user-facing web interface. It serves the containerized UI for employees and managers to submit and review time-off requests.
* **Cloud Run (Backend)**: This service acts as the core API and business logic layer. The frontend service communicates directly with this backend service to process rules, validate requests, and handle data routing.
* **Cloud SQL / AlloyDB**: This service acts as the primary relational database. It manages strongly consistent, transactional records, which include employee profiles, department hierarchies, and accrued vacation time balances. It currently runs as a standalone, single-region instance without cross-region replication.
* **Firestore**: This service acts as a NoSQL document store to manage asynchronous data. It tracks the dynamic state of vacation approval workflows, temporary session data, and user notifications.
* **Virtual Private Cloud (VPC)**: This service provides the foundational network boundary. Serverless VPC access connectors and private service networking securely connect all serverless and database components, isolating the application from the public internet.

In this lab, you use agentic tools to interact with Google Cloud in new ways, leveraging AI capabilities to upgrade the brownfield application so that it meets customer requirements.

---

## 🎓 What Googlers Will Learn

1. **Choose the Best Tool for the Right Task**: Seamlessly select and utilize the VS Code Antigravity Plugin, the Antigravity CLI, Antigravity 2.0, and Google Cloud MCP services.
2. **Master Agentic Context Engineering**: Explain context engineering, including why you create README files and architecture diagrams and how agents leverage them for grounded reasoning.
3. **Analyze Workloads via Agentic AI**: Use agentic AI tools to discover and analyze a customer's existing Google Cloud application.
4. **Document Logical Architecture**: Document the logical architecture of the customer's existing brownfield workload.
5. **Summarize Google Cloud Components**: Synthesize GCP services and generate a high-level summary document for technical and executive discussion.
6. **Analyze Customer Requirements & Transcripts**: Analyze customer requirement documents and call transcripts from previous alignment meetings.
7. **Generate Application Enhancements**: Produce a structured list of application enhancements to improve system resiliency.
8. **Declarative IaC Updates**: Update the existing application in the primary region using traditional declarative methods, such as Terraform.
9. **Agentic Code Generation**: Generate updates to existing Terraform HCL code using agentic AI pair-programming tools.
10. **Imperative Deployment Methods**: Deploy updates to the secondary target region using imperative methods, such as tool calling with the Google Cloud CLI or Google Cloud MCP services.
11. **Compare Deployment Methodologies**: Contrast imperative deployment methods with traditional declarative methods.
12. **Resilience & Health Verification**: Test the updated multi-region application to verify that it functions correctly, is highly resilient, and meets all customer SLAs.

---

## 🏢 Learning Scenario: Infrastructure Modernization for Cymbal Group

You are a Platform Cloud Engineer brought in to deliver a critical infrastructure modernization solution for your customer, the **Enterprise Architecture division at Cymbal Group**.

Cymbal Group relies on a critical internal HR portal—specifically the **Vacation Request Subsystem**—to handle time-off scheduling and accrued balance logic for all international subsidiaries across its retail, healthcare, and financial service sectors. Currently, this system is deployed as a single-region brownfield application. During peak quarterly review cycles, localized regional latency spikes heavily degrade performance, and a recent minor outage in the host region completely locked out thousands of employees.

Recognizing the operational risk, the Cymbal Group Enterprise Architecture team has compiled a strict set of technical directives and migration requirements. Your objective in this workshop is to execute your customer's design, migrating their application from its vulnerable single-region footprint into a highly available, globally distributed, multi-region architecture. You will leverage modern deployment practices—including agentic IDEs (like the VS Code Antigravity Plugin) and CLIs—to safely expand their network, provision distributed databases, and deploy their decoupled compute services.

### Problem Identification
The customer's current HR solution has structural limitations that you must eliminate during modernization:
1. **Regional Blocker**: The frontend and backend Cloud Run services reside entirely inside a single Google Cloud region. The primary Cloud SQL and Firestore database instances also reside in this single region. A localized outage causes a total loss of availability for Cymbal Group.
2. **Database Scalability Limitations**: The single-region Cloud SQL instance forces global corporate traffic to route to one geographic location for all transactional reads. This configuration causes unacceptable latency for remote Cymbal subsidiaries in Europe and Asia.
3. **Coupled Traffic Routing**: The legacy architecture routes traffic directly to the regional Cloud Run service. The architecture lacks the intelligence to balance the load globally or fail over during regional degradation.

---

## 📋 High-Level Task List

```
+-----------------------------------------------------------------------------------+
| TASK 1: Install & Use Agentic AI Tools, Generate Baseline Diagram & Summary Docs   |
+-----------------------------------------------------------------------------------+
                                         │
                                         ▼
+-----------------------------------------------------------------------------------+
| TASK 2: Analyze Customer Requirements & Call Transcripts, Draft Resiliency List   |
+-----------------------------------------------------------------------------------+
                                         │
                                         ▼
+-----------------------------------------------------------------------------------+
| TASK 3: Deploy Primary Region Enhancements via Declarative Terraform              |
+-----------------------------------------------------------------------------------+
                                         │
                                         ▼
+-----------------------------------------------------------------------------------+
| TASK 4: Imperative Multi-Region Expansion & Compute Decoupling (Region 2 / GCLB)  |
+-----------------------------------------------------------------------------------+
                                         │
                                         ▼
+-----------------------------------------------------------------------------------+
| TASK 5: Test Modernized Application, Verify Resiliency & Execute DR Failover      |
+-----------------------------------------------------------------------------------+
```

---

## 🛠️ Step-by-Step Task Execution Instructions

---

### Task 1: Workload Discovery & Baseline Architecture Documentation

In this task, you install and use agentic AI tools (VS Code Antigravity Plugin, Antigravity CLI, Antigravity 2.0) to inspect the brownfield codebase under `Lab1/ce-sample-hr-vacation` and generate baseline topology documentation.

#### Step 1.1: Analyze Existing Codebase
Prompt your Agentic AI IDE:
```text
Inspect the application codebase and infrastructure templates under Lab1/ce-sample-hr-vacation. 
Identify all active Google Cloud services, networking boundaries, database connections, and ingress routing rules.
```

#### Step 1.2: Generate Baseline Summary Document & Architecture Diagram
Instruct the Agentic AI tool to produce:
1. `docs/baseline_summary.md`: A high-level document describing all active GCP services, single-region dependencies, and SPOF risks.
2. `docs/baseline_architecture.mermaid`: A Mermaid architecture diagram illustrating the baseline single-region flow.

*Note: We will share what good looks like during verification.*

> 🤖 **Scoring Check 1**: Upload `baseline_summary.md` and `baseline_architecture.mermaid`. An LLM Judge validates that your documents match reference materials by **at least 80 percent**.

---

### Task 2: Analyze Customer Requirements & Call Transcripts

Review customer requirement documents and call transcripts from a previous meeting to construct an updated resiliency blueprint.

#### Step 2.1: Ingest Customer Transcripts
Open and inspect [docs/customer_requirements.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab1/docs/customer_requirements.md).

Prompt your Agentic AI IDE:
```text
Analyze docs/customer_requirements.md and extract Cymbal Group's key latency, availability, caching, and multi-region routing mandates into a structured enhancement list.
```

#### Step 2.2: Generate Updated Summary & Architecture Blueprint
Produce the target state artifacts:
1. `docs/updated_summary.md`: Outlining specifications for cross-region database replication, multi-region Firestore, Memorystore for Redis caching, and GCLB Anycast routing.
2. `docs/updated_architecture.mermaid`: Target state architecture diagram depicting symmetric dual-region Cloud Run services and Anycast load balancing.

> 🤖 **Scoring Check 2**: Upload `updated_summary.md` and `updated_architecture.mermaid`. An LLM Judge validates **at least 80 percent alignment** with customer reference specifications.

---

### Task 3: Upgrading to Multi-Region Load Balancing & Declarative Primary Deployment

To support low-latency global transactions for subsidiaries in Europe and Asia, you must upgrade the baseline single-region configuration into a highly available, multi-regional topology.

Follow these step-by-step instructions to update your application code and IaC templates to be multi-regional:

#### Step 3.1: Declare a Second Regional Cloud Run App Service
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

---

### Task 4: Imperative Multi-Region Expansion & Compute Decoupling

In this task, you expand into `europe-west1` using imperative tool calling with the Google Cloud CLI or Google Cloud MCP services, comparing imperative deployment methods to traditional declarative methods.

#### Step 4.1: Create a European Serverless NEG
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

#### Step 4.2: Register Both Regional NEGs to the Backend Service
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

#### Step 4.3: Configure Cross-Region AlloyDB Replication & Private DNS
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

#### Step 4.4: Contrast Declarative vs. Imperative Approaches
Document a comparison in `docs/imperative_vs_declarative.md` evaluating the tradeoffs of stateful declarative lifecycle management (Terraform) vs. rapid imperative tool calling (`gcloud` CLI / MCP).

---

### Task 5: Verify the Multi-Regional Setup, Resiliency & Failover

1. Apply the updated Terraform configuration (`terraform apply`).
2. Verify that GCLB forwards traffic to both `us-central1` and `europe-west1` based on user location.
3. Access the portal and inspect the simulated terminal logs. Confirm that requests are routed securely to the nearest database node!
4. Practice a simulated disaster recovery failover by promoting the Secondary AlloyDB cluster in `europe-west1` and redirecting Cloud DNS `write-db.hr-vacation.internal.` record to point to the promoted instance without redeploying the backend.
5. Run automated verification suite:
   ```bash
   bash verify.sh
   ```

> 🤖 **Scoring Check 3**: Background agentic AI tools inspect your updated Google Cloud environment, compare it against customer requirements and transcripts, capture the final summary document and architecture diagram, and an LLM Judge validates final documents against reference materials.

---

## 📊 Validation & Scoring Criteria Summary

| Validation Rule | Requirement Description | Weight |
|---|---|---|
| **Zero Manual Console Policy** | Direct interaction with `console.cloud.google.com` is prohibited. Agentic AI tool usage is verified via tool logs. | Mandatory Pass |
| **Task 1 Baseline Artifacts** | `baseline_summary.md` and `baseline_architecture.mermaid` match reference materials by ≥80% (validated by LLM Judge). | 20 Points |
| **Task 2 Requirements Blueprint** | `updated_summary.md` and `updated_architecture.mermaid` match reference specifications by ≥80% (validated by LLM Judge). | 20 Points |
| **Task 3 Declarative Primary Region** | Terraform code generated and applied to provision primary VPC, DB, and compute tier in `us-central1`. | 20 Points |
| **Task 4 Imperative Secondary Expansion** | Secondary region (`europe-west1`) app service, NEGs, and DR replication deployed imperatively via CLI/MCP. | 20 Points |
| **Task 5 Resiliency & Failover Verification** | Multi-region deployment passes health checks, primary region removal test, and final LLM Judge validation. | 20 Points |

---
*End of Module 1 - Phase 1 Student Lab Guide.*
