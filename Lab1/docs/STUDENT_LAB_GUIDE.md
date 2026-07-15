# Lab 1 Student Lab Guide: Modernizing GCP Workloads via Agentic Tools
**Module 1 - Phase 1 | Learning Lab (Build)**

---

## 📌 Quick Overview & Constraints

| Metric | Details |
|---|---|
| **Lab Title** | Module 1 - Phase 1: Modernizing GCP Workloads via Agentic Tools |
| **Lab Format** | Learning Lab (Guided Scenario-Driven Build) |
| **Learner Profile** | Practice CE, Platform CE (incl. PA), Outcome CE, GCC Engineers |

> ⚠️ **ZERO-CONSOLE POLICY**: Direct interaction with `console.cloud.google.com` is strictly prohibited. You MUST use Agentic AI tools (VS Code Antigravity Extension, Antigravity CLI, Agent Skills, `gcloud` MCP) for all discovery, code refactoring, deployment, and testing.

---

## 📝 Lab Summary

In this lab, you transition from application engineering to cloud production operations on Google Cloud. Using Agentic AI tools (VS Code Antigravity Plugin, Antigravity CLI, Antigravity 2.0, MCP), you discover a single-region brownfield HR application (`ce-sample-hr-vacation`), analyze customer feedback from Cymbal Group, and upgrade the system into a resilient, multi-region architecture.

### Core Google Cloud Services Used:
* **Cloud Run (Frontend & Backend)**: Containerized UI and API layers.
* **AlloyDB / Cloud SQL**: Relational database for transactional employee records and accrual balances.
* **Firestore**: NoSQL document store for async workflow states and notifications.
* **VPC & Serverless Access**: Foundational network boundary and private service connectors.

---

## 🎓 Learning Objectives

1. **Agentic Tooling & Context Engineering**: Select the right agentic tools and construct READMEs and architecture diagrams for grounded AI reasoning.
2. **Workload Analysis**: Discover brownfield GCP applications and synthesize customer meeting transcripts.
3. **Multi-Region Modernization**: Deploy primary region resources declaratively via Terraform IaC and secondary region resources imperatively via CLI/MCP.
4. **Resiliency Verification**: Test Anycast load balancing, local database latency (<50ms), and execute disaster recovery failover.

---

## 🏢 Scenario & Problem Identification

You are consulting for **Cymbal Group's Enterprise Architecture Division**. Their internal **Vacation Request Subsystem** operates in a single region (`us-central1`). During peak cycles, remote international subsidiaries experience severe latency, and recent regional outages locked out 15,000 employees.

### Key Technical Blockers to Eliminate:
1. **Single-Region SPOF**: All compute and database instances reside solely in `us-central1`.
2. **Database Read Bottlenecks**: Global read queries route to a single database node, causing >800ms latency.
3. **Unbalanced Ingress**: Traffic routes directly to regional Cloud Run without global Anycast failover.

---

## 📋 High-Level Task Execution Flow

```
1. Discovery & Baseline Docs  ➜  2. Customer Requirements Analysis  ➜  3. Declarative Primary IaC
                                                                             │
5. DR Verification & Failover    4. Imperative Secondary Expansion ◄────────┘
```

---

## 🛠️ Step-by-Step Task Instructions

---

### Task 1: Workload Discovery & Baseline Architecture

Use your Agentic AI IDE to analyze the brownfield codebase under `Lab1/ce-sample-hr-vacation`.

> [!NOTE]
> **🤖 AI Pair-Programming Prompt**:
> ```text
> Inspect the application codebase and infrastructure templates under Lab1/ce-sample-hr-vacation. 
> Identify active GCP services, networking boundaries, database connections, and single-region dependencies. 
> Create two output files in the docs/ directory:
> 1. docs/baseline_summary.md: Describing single-region GCP services, dependencies, and SPOF risks.
> 2. docs/baseline_architecture.mermaid: A Mermaid flowchart depicting the baseline single-region architecture.
> ```

*Note: We will share what good looks like during verification.*

> 🤖 **Scoring Check 1**: LLM Judge validates `baseline_summary.md` and `baseline_architecture.mermaid` match reference specs by **≥80%**.

---

### Task 2: Customer Requirements Analysis & Blueprinting

Ingest customer feedback to design the target multi-region architecture.

1. Open and inspect [docs/customer_requirements.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab1/docs/customer_requirements.md).
2. **AI Prompt Instructions**:
   > [!NOTE]
   > **🤖 AI Pair-Programming Prompt**:
   > ```text
   > Read docs/customer_requirements.md. Extract Cymbal Group's latency, availability, caching, and multi-region routing mandates.
   > Generate two target artifacts in the docs/ directory:
   > 1. docs/updated_summary.md: A technical specification detailing cross-region database replication, multi-region Firestore, Redis caching, and GCLB Anycast routing.
   > 2. docs/updated_architecture.mermaid: A Mermaid diagram showing symmetric dual-region Cloud Run services and Anycast global load balancing.
   > ```

> 🤖 **Scoring Check 2**: LLM Judge validates `updated_summary.md` and `updated_architecture.mermaid` match customer specs by **≥80%**.

---

### Task 3: Upgrading to Multi-Region Load Balancing (Steps 1–3)

Use your Agentic AI IDE to generate and refactor your Terraform configuration in `terraform/main.tf`.

#### Step 1: Declare European Cloud Run App Service
> [!NOTE]
> **🤖 AI Pair-Programming Prompt**:
> ```text
> In terraform/main.tf, declare a new Google Cloud Run v2 service resource named "app_europe" (service name "hr-vacation-app-europe") in region "europe-west1".
> Configure:
> - Container image pointing to the app image in Artifact Registry.
> - Ingress set to "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER".
> - Environment variables: DB_WRITE_HOST = "write-db.hr-vacation.internal", DB_READ_HOST = "read-db.hr-vacation.internal", and DB_PASS.
> - Outbound vpc_access connector set to google_vpc_access_connector.vpc_connector.id with egress = "ALL_TRAFFIC".
> ```

#### Step 2: Create European Serverless NEG
> [!NOTE]
> **🤖 AI Pair-Programming Prompt**:
> ```text
> Add a regional serverless Network Endpoint Group resource named "serverless_neg_europe" (NEG name "hr-vacation-neg-europe") in region "europe-west1" in terraform/main.tf. Configure the cloud_run block to target google_cloud_run_v2_service.app_europe.name.
> ```

#### Step 3: Register Both Regional NEGs to GCLB Backend Service
> [!NOTE]
> **🤖 AI Pair-Programming Prompt**:
> ```text
> Update the google_compute_backend_service resource named "backend_service" in terraform/main.tf to add a second backend block referencing the European serverless NEG ID (google_compute_region_network_endpoint_group.serverless_neg_europe.id), so traffic is balanced across both US and European NEGs.
> ```

---

### Task 4: Cross-Region AlloyDB Replication & Private DNS (Step 4)

#### Step 4: Provision DR Secondary Cluster & Cloud DNS Record Set
Use your Agentic AI IDE to configure cross-region database replication and DNS abstraction.

> [!NOTE]
> **🤖 AI Pair-Programming Prompt**:
> ```text
> In terraform/main.tf, add the following cross-region replication and DNS abstraction resources:
> 1. An AlloyDB cluster resource named "secondary" (cluster_id "hr-vacation-cluster-secondary") in "europe-west1" with cluster_type set to "SECONDARY", connected to the VPC network, and referencing the primary cluster name in secondary_config.
> 2. An AlloyDB instance resource named "secondary_instance" in "europe-west1" with instance_type "SECONDARY" inside the secondary cluster, with cpu_count = 2 and depends_on the primary instance.
> 3. A Cloud DNS record set resource named "write_dns" under the private managed zone mapping "write-db.hr-vacation.internal." to the primary database instance IP address.
> 4. Generate a comparative analysis note in docs/imperative_vs_declarative.md comparing declarative IaC management against imperative CLI operations.
> ```

---

### Task 5: System Verification & DR Failover Promotion (Step 5)

Validate your deployment and perform a simulated disaster recovery failover.

> [!NOTE]
> **🤖 AI Pair-Programming Prompt**:
> ```text
> Guide me to:
> 1. Initialize and apply the updated Terraform code (terraform init && terraform apply).
> 2. Test global Anycast routing latency using curl probes against the GCLB domain (https://hr-vacation.gcp-lab.internal/api/health).
> 3. Practice a simulated DR failover by promoting the Secondary AlloyDB cluster in europe-west1 and updating the write-db.hr-vacation.internal DNS record to point to the promoted instance without redeploying the backend application.
> 4. Execute automated verification: bash verify.sh
> ```

---

## 📊 Summary Scoring Matrix

| Task Area | Deliverable / Verification Standard | Weight |
|---|---|---|
| **Zero Console Policy** | 100% execution via Agentic AI IDE / CLI / MCP | Required |
| **Task 1 Baseline Artifacts** | `baseline_summary.md` & `baseline_architecture.mermaid` (LLM Judge ≥80%) | 20 Points |
| **Task 2 Requirements Blueprint** | `updated_summary.md` & `updated_architecture.mermaid` (LLM Judge ≥80%) | 20 Points |
| **Task 3 Declarative Primary IaC** | Primary region Cloud Run, NEGs, and GCLB configured in Terraform | 20 Points |
| **Task 4 Secondary DR Replication** | AlloyDB Secondary cluster, instance & Private DNS set up in `europe-west1` | 20 Points |
| **Task 5 Resilience & DR Failover** | `verify.sh` passes health checks and AlloyDB DR promotion failover test | 20 Points |

---
*End of Lab 1 Student Lab Guide.*
