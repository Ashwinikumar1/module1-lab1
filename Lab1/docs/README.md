# Module 1 - Phase 1: Modernizing GCP Workloads via Agentic Tools

Welcome to **Lab 1: Modernizing GCP Workloads via Agentic Tools** (Module 1 - Phase 1). This repository contains the source code, Terraform configurations, and student guides for the **Cymbal Group Vacation Request Subsystem Modernization** scenario.

> 📖 **Primary Student Guides**:
> * **[Lab 1 Student Lab Guide (Module 1 - Phase 1)](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab1/docs/STUDENT_LAB_GUIDE.md)**: Step-by-step guide for workload discovery, customer transcript analysis, declarative & imperative multi-region deployment, and failover verification.
> * **[Customer Requirements & Call Transcripts](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab1/docs/customer_requirements.md)**: Official customer meeting notes and technical requirement specifications from Cymbal Group.
> * **[Lab Setup Guide](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab1/docs/lab_setup_guide.md)**: Local environment preparation, gcloud authentication, and Terraform variable auto-detection.

---

## 📖 Scenario Overview

Cymbal Group relies on a critical internal HR portal—specifically the **Vacation Request Subsystem**—to handle time-off scheduling and accrued balance logic across international subsidiaries in retail, healthcare, and financial services.

Currently, the system is deployed as a single-region brownfield application in `us-central1`. During quarterly review peaks, European and Asian users experience severe latency (>800ms). Furthermore, a recent single-region failure resulted in a complete outage locking out 15,000 employees.

In this lab, you act as a Lead Platform & Cloud Solutions Engineer. You use **Agentic AI tools** (VS Code Antigravity Extension, Antigravity CLI, Google Agent Skills, and MCP) to analyze the workload, discover the baseline architecture, process customer call transcripts, and migrate the system into a resilient multi-region topology.

### Repository Structure
* **`ce-sample-hr-vacation/`**: Starter single-region brownfield codebase for student deployment (`https://github.com/alanpoole/ce-sample-hr-vacation`).
* **`solution/`**: Complete multi-region modernization solution reference (`solution/app` and `solution/terraform`).
* **`docs/`**: Lab guides, customer requirement call transcripts, and architecture specification templates.
* **`verify.sh`**: Automated 5-task lab scoring and verification suite.

---

## 📖 Scenario Overview
1. **Cloud Run (Frontend & Backend)**: Containerized microservices deployed symmetrically in `us-central1` and `europe-west1`.
2. **Cloud SQL (PostgreSQL)**: Primary transactional database in `us-central1` with a Cross-Region Read Replica in `europe-west1`.
3. **Firestore (Native)**: Multi-region document store capturing asynchronous approval states (`/workflows`) and notifications (`/notifications`).
4. **Memorystore for Redis**: High-performance in-memory caching tier within the private VPC to accelerate frequent balance lookups.
5. **Global External Application Load Balancer (GCLB)**: Global Anycast IP load balancer with Serverless NEGs for multi-region routing and zero-downtime failover.
6. **Virtual Private Cloud (VPC)**: Foundational private network with Serverless VPC Access connectors and Private Service Access.

---

## 🧪 High-Level Task Execution Summary

1. **Task 1: Workload Discovery & Baseline Architecture Documentation**
   * Inspect code (`Lab1/app`) and IaC (`Lab1/terraform`).
   * Generate `baseline_summary.md` and `baseline_architecture.mermaid` (Validated by LLM Judge ≥80%).
2. **Task 2: Analyze Customer Requirements & Call Transcripts**
   * Read `docs/customer_requirements.md`.
   * Generate `updated_summary.md` and `updated_architecture.mermaid` (Validated by LLM Judge ≥80%).
3. **Task 3: Modernize Primary Infrastructure via Declarative Terraform**
   * Update `terraform/main.tf` to provision primary network, Cloud SQL master, Firestore multi-region, and Memorystore for Redis in `us-central1`.
   * Run `terraform init` and `terraform apply`.
4. **Task 4: Imperative Multi-Region Expansion & Compute Decoupling**
   * Deploy secondary subnet, Cloud SQL cross-region replica, Cloud Run services (`hr-vacation-frontend-europe`, `hr-vacation-backend-europe`), and GCLB Serverless NEGs imperatively using `gcloud` CLI / MCP tool calls.
   * Document declarative vs. imperative comparison in `docs/imperative_vs_declarative.md`.
5. **Task 5: Multi-Region Resilience Validation & Failover Verification**
   * Run health checks and probe local read latency (<50ms).
   * Simulate `us-central1` outage and verify zero-downtime failover to `europe-west1`.
   * Execute automated score verification: `bash verify.sh`.

---

## 🛠️ Getting Started Locally & Provisioning

### 1. Provision Baseline Infrastructure with Terraform
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Run Application Container Locally
```bash
cd ../app
npm install
npm start
# Access at http://localhost:8080
```

### 3. Automated Score & Verification Suite
```bash
cd ..
bash verify.sh
```

---
*Module 1 - Phase 1 Documentation.*
