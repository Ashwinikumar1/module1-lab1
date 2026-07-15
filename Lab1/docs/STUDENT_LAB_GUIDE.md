# Lab 1: Modernizing GCP Workloads via Agentic Tools (Module 1 - Phase 1)

Welcome to **Lab 1: Learning Lab** of Module 1. In this hands-on lab, you act as a Lead Platform & Cloud Solutions Engineer consulting for **Cymbal Group's Enterprise Architecture Division**. You will analyze, document, modernize, and deploy a highly available, multi-region architecture for the **Cymbal HR Vacation Request Subsystem** using Agentic AI tools, Google Agent Skills, Terraform, and the Model Context Protocol (MCP).

> ⚠️ **CRITICAL LAB DISCIPLINE & RESTRICTION**: You are operating in a production governance scenario. **Direct manual web interaction with the Google Cloud Console (`console.cloud.google.com`) is strictly prohibited.** You MUST use Agentic AI tools (VS Code Antigravity Extension, Antigravity CLI, Google Agent Skills, and `gcloud` via terminal/MCP) for all infrastructure discovery, code updates, declarative IaC execution, imperative CLI tool calls, and health verifications.

---

## 🎯 Learning Objectives

By completing this lab, you will learn how to:
1. **Choose the Best Tool for the Right Task**: Seamlessly navigate between the VS Code Antigravity Plugin, Antigravity CLI, Antigravity 2.0, and `gcloud` MCP tools.
2. **Master Agentic Context Engineering**: Understand why creating README files, architecture diagrams, and system documentation is essential for grounded agent reasoning.
3. **Discover & Document Brownfield Workloads**: Use Agentic AI tools to analyze an existing single-region Google Cloud application and generate logical architecture diagrams and summary reports.
4. **Analyze Customer Requirements & Meeting Transcripts**: Synthesize business feedback, latency requirements, and regional failure risks into actionable technical directives.
5. **Declarative Infrastructure Modernization**: Generate and apply Terraform code updates to provision foundational networks, Cloud SQL, Firestore, and Memorystore for Redis in the primary region.
6. **Imperative Multi-Region Expansion**: Deploy secondary-region compute (`europe-west1`) and cross-region Cloud SQL read replicas imperatively using `gcloud` CLI tool calls and MCP services.
7. **Evaluate Declarative vs. Imperative Methodologies**: Compare declarative IaC against imperative tool-calling deployment workflows in multi-region environments.
8. **Verify System Resiliency & Failover**: Test multi-region Anycast routing via a Global External Application Load Balancer with Serverless NEGs and validate health checks under simulated regional failure.

---

## 👥 Intended Learner Profile

* **Target Audience**: Practice CEs, Platform CEs (incl. Partner Advisors), Outcome CEs, and GCC Engineers.
* **Lab Format**: **Learning Lab (Build)** — Guided scenario-driven analysis, refactoring, and step-by-step multi-region cloud engineering.

---

## 🏢 Business Scenario: Infrastructure Modernization for Cymbal Group

Cymbal Group relies on a critical internal HR portal—specifically the **Vacation Request Subsystem**—to handle time-off scheduling and accrued balance logic for international subsidiaries across retail, healthcare, and financial service sectors. 

Currently, this system operates as a single-region brownfield deployment in `us-central1`. During peak quarterly review cycles, localized regional latency spikes heavily degrade performance for European and Asian subsidiaries. A recent minor outage in the host region completely locked out over 15,000 employees.

Recognizing the operational risk, Cymbal Group's Enterprise Architecture team has compiled a strict set of technical directives and migration requirements. Your objective is to execute your customer's design, migrating the application from its vulnerable single-region footprint into a highly available, globally distributed, multi-region architecture.

### Problem Identification
The customer's legacy HR solution has three major structural limitations:
1. **Regional Blocker**: The Cloud Run frontend, backend, primary Cloud SQL PostgreSQL instance, and Firestore database reside entirely in a single Google Cloud region (`us-central1`). A regional failure causes total loss of application availability.
2. **Database Scalability Bottlenecks**: The single-region database forces global corporate traffic to route to `us-central1` for all transactional reads, causing unacceptable >800ms latency for remote subsidiaries.
3. **Coupled Traffic Routing**: The legacy architecture routes traffic directly to the regional Cloud Run URL, lacking global load balancing, Anycast IP routing, or automatic regional failover capabilities.

---

## 📋 High-Level Task Overview

```
+-----------------------------------------------------------------------------------+
| TASK 1: Workload Discovery & Baseline Architecture Documentation (Agentic Discovery)|
+-----------------------------------------------------------------------------------+
                                         │
                                         ▼
+-----------------------------------------------------------------------------------+
| TASK 2: Analyze Customer Requirements & Generate Resiliency Enhancements         |
+-----------------------------------------------------------------------------------+
                                         │
                                         ▼
+-----------------------------------------------------------------------------------+
| TASK 3: Modernize Core Infrastructure via Declarative Terraform (Region 1 / Shared)|
+-----------------------------------------------------------------------------------+
                                         │
                                         ▼
+-----------------------------------------------------------------------------------+
| TASK 4: Imperative Multi-Region Expansion & Compute Decoupling (Region 2 / GCLB)  |
+-----------------------------------------------------------------------------------+
                                         │
                                         ▼
+-----------------------------------------------------------------------------------+
| TASK 5: Multi-Region Resilience Verification, Health Checks & Failover Testing    |
+-----------------------------------------------------------------------------------+
```

---

## 🛠️ Detailed Lab Execution Steps

---

### Task 1: Workload Discovery & Baseline Architecture Documentation

In this task, you use Agentic AI IDE features and MCP tools to inspect the brownfield codebase (`Lab1/ce-sample-hr-vacation` cloned from `https://github.com/alanpoole/ce-sample-hr-vacation`) and generate baseline topology documentation.

#### Step 1.1: Analyze the Existing Workload Codebase
Prompt your Agentic AI IDE (or Antigravity CLI) to analyze the project:
```text
Inspect the application codebase and infrastructure templates under Lab1/ce-sample-hr-vacation. 
Identify all active Google Cloud services, networking boundaries, database connections, and ingress routing rules.
```

#### Step 1.2: Generate Baseline Summary Document & Architecture Diagram
Instruct the Agentic AI tool to generate two output artifacts in your workspace:
1. `docs/baseline_summary.md`: A high-level description of all Google Cloud components, service dependencies, and single-region vulnerability risks.
2. `docs/baseline_architecture.mermaid`: A standard Mermaid sequence/flow diagram illustrating the baseline topology.

Example Mermaid snippet for baseline architecture:
```mermaid
graph TD
    User([Global Employees]) -->|Direct HTTP Ingress| CloudRunFE[Cloud Run Frontend: us-central1]
    CloudRunFE -->|Serverless VPC Connector| CloudRunBE[Cloud Run Backend API: us-central1]
    CloudRunBE -->|Private Service Access| CloudSQL[(Cloud SQL PostgreSQL: us-central1)]
    CloudRunBE -->|Private Connection| Firestore[(Firestore Native Collection: us-central1)]
```

> 🤖 **Automated Scoring Check 1**: The lab environment uploads `baseline_summary.md` and `baseline_architecture.mermaid`. An LLM Judge validates that your baseline artifacts match the reference architecture by **at least 80 percent**.

---

### Task 2: Analyze Customer Requirements & Call Transcripts

Review feedback from the previous customer alignment meeting to determine technical gaps and produce an updated architecture blueprint.

#### Step 2.1: Ingest Customer Transcripts & Directives
Open and examine [customer_requirements.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab1/docs/customer_requirements.md).

Prompt your Agentic AI tool:
```text
Analyze docs/customer_requirements.md and summarize Cymbal Group's key latency, availability, caching, and multi-region routing mandates into a structured enhancement list.
```

#### Step 2.2: Generate Updated Architecture Artifacts
Instruct the agent to update your documentation to reflect the proposed target multi-region architecture:
1. `docs/updated_summary.md`: Outlining the technical specification for cross-region Cloud SQL replication, multi-region Firestore, Memorystore for Redis caching, and GCLB Anycast routing.
2. `docs/updated_architecture.mermaid`: Target state architecture diagram showing symmetric dual-region Cloud Run services and cross-region database flows.

> 🤖 **Automated Scoring Check 2**: The lab validator captures `updated_summary.md` and `updated_architecture.mermaid`. An LLM Judge verifies an **80%+ alignment** with customer requirements.

---

### Task 3: Modernize Core Infrastructure via Declarative Terraform (Region 1 & Shared Tier)

Provision the primary region network, Cloud SQL master, Firestore multi-region database, and Memorystore for Redis caching instance using Terraform.

#### Step 3.1: Refactor Baseline IaC Configuration
Use Agentic AI pair programming to update `terraform/main.tf`:
- Add Memorystore for Redis instance (`google_redis_instance.cache`).
- Enable Firestore multi-region database location (`nam5` or `eur3`).
- Set up Serverless VPC Access connector for `us-central1`.

#### Step 3.2: Initialize and Apply Terraform
Execute the declarative workflow:
```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

---

### Task 4: Imperative Multi-Region Expansion & Compute Decoupling (Region 2 & GCLB)

In this task, you expand into `europe-west1` using **imperative tool calling with the Google Cloud CLI or Google Cloud MCP services**, demonstrating imperative operations alongside traditional IaC.

#### Step 4.1: Deploy Cloud SQL Cross-Region Read Replica Imperatively
Prompt your Agentic IDE or execute via CLI MCP:
```bash
gcloud sql instances create hr-vacation-sql-db-replica \
  --master-instance-name=hr-vacation-sql-db \
  --region=europe-west1 \
  --tier=db-f1-micro \
  --database-version=POSTGRES_15 \
  --no-assign-ip \
  --network=projects/$GCP_PROJECT_ID/global/networks/hr-vacation-vpc
```

#### Step 4.2: Deploy Secondary Compute Services (`europe-west1`)
Imperatively build and deploy the Cloud Run frontend and backend in `europe-west1`:
```bash
# Build and Push Image
gcloud builds submit --tag europe-west1-docker.pkg.dev/$GCP_PROJECT_ID/ce-sample-hr-vacation-repo/backend:latest ./app

# Deploy European Cloud Run Service
gcloud run deploy hr-vacation-backend-europe \
  --image europe-west1-docker.pkg.dev/$GCP_PROJECT_ID/ce-sample-hr-vacation-repo/backend:latest \
  --region europe-west1 \
  --ingress internal-and-cloud-load-balancing \
  --set-env-vars DB_READ_HOST="10.200.0.5",REDIS_HOST="10.200.1.5"
```

#### Step 4.3: Configure Global Load Balancer & Serverless NEGs
Imperatively link both regional Cloud Run services to a Global External Application Load Balancer:
```bash
# Create Serverless NEGs for US and EU
gcloud compute network-endpoint-groups create hr-vacation-neg-us \
  --region=us-central1 \
  --network-endpoint-type=serverless \
  --cloud-run-service=hr-vacation-frontend-us

gcloud compute network-endpoint-groups create hr-vacation-neg-eu \
  --region=europe-west1 \
  --network-endpoint-type=serverless \
  --cloud-run-service=hr-vacation-frontend-europe

# Attach NEGs to Load Balancer Backend Service
gcloud compute backend-services add-backend hr-vacation-global-backend \
  --global \
  --network-endpoint-group=hr-vacation-neg-us \
  --network-endpoint-group-region=us-central1

gcloud compute backend-services add-backend hr-vacation-global-backend \
  --global \
  --network-endpoint-group=hr-vacation-neg-eu \
  --network-endpoint-group-region=europe-west1
```

#### Step 4.4: Document Declarative vs. Imperative Analysis
Create a comparison note in `docs/imperative_vs_declarative.md` contrasting stateful declarative lifecycle management (Terraform) with rapid imperative CLI operations (`gcloud`/MCP).

---

### Task 5: Resilience Validation, Health Checks & Failover Verification

Validate the modernized multi-region environment under normal and failure states.

#### Step 5.1: Execute Health Check & Latency Probes
Run global latency checks against the GCLB Anycast VIP:
```bash
curl -w "Connect Time: %{time_connect}s | Total Latency: %{time_total}s\n" \
  -s -o /dev/null https://hr-vacation.gcp-lab.internal/api/health
```

#### Step 5.2: Simulate Regional Failover Outage
Simulate a failure in `us-central1` by scaling primary US compute instances to 0 or disabling the US NEG backend:
```bash
gcloud compute backend-services update-backend hr-vacation-global-backend \
  --global \
  --network-endpoint-group=hr-vacation-neg-us \
  --network-endpoint-group-region=us-central1 \
  --capacity-scaler=0.0
```
Re-run health checks to confirm 100% traffic rerouting to `europe-west1` with zero downtime and <50ms read latency.

#### Step 5.3: Run Automated Verification Suite
Execute the automated grading script:
```bash
bash verify.sh
```

> 🤖 **Automated Scoring Check 3**: Background Agentic AI tools inspect your live Google Cloud environment, generate a final environment summary document, and run an LLM Judge comparison against reference materials to calculate your final score.

---

## 📊 Summary Rubric & Validation Matrix

| Scoring Criterion | Threshold / Standard | Weight |
|---|---|---|
| **Zero Manual Console Access** | 100% actions logged via Agentic IDE / CLI / MCP (`console.cloud.google.com` unused) | Required Pass |
| **Baseline Architecture Document** | `baseline_summary.md` and `baseline_architecture.mermaid` uploaded (LLM Judge match ≥80%) | 20 Points |
| **Customer Requirements Analysis** | `updated_summary.md` and `updated_architecture.mermaid` uploaded (LLM Judge match ≥80%) | 20 Points |
| **Declarative Primary Region Modernization** | Terraform applied for VPC, Cloud SQL Master, Firestore, Redis in `us-central1` | 20 Points |
| **Imperative Secondary Expansion** | Cloud Run, Cross-Region Read Replica & GCLB NEGs deployed via `gcloud`/MCP in `europe-west1` | 20 Points |
| **Resiliency & Failover Verification** | `verify.sh` passes health checks and regional failover test with <50ms read latency | 20 Points |

---
*End of Lab 1 Student Lab Guide.*
