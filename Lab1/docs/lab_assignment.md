# Lab 1 Coursework: Modernizing GCP Workloads via Agentic Tools
**Module 1 - Phase 1: High Availability, Global Routing & Latency Optimization**

## Objective
In this hands-on lab assignment, you will modernize Cymbal Group's single-region HR Vacation Request subsystem into a highly available, latency-optimized multi-region architecture. You will use Agentic AI tools (VS Code Antigravity Plugin, Antigravity CLI, Google Agent Skills, MCP) to analyze existing code, process customer meeting feedback, apply declarative Terraform IaC for primary region resources, imperatively deploy secondary region resources via CLI tool calling, and execute automated failover verification.

---

## Assignment Tasks & AI Pair-Programming Prompts

### Step 1: Discover Workload & Generate Baseline Topology Docs
Use your Agentic AI IDE to analyze `Lab1/ce-sample-hr-vacation`. Generate `docs/baseline_summary.md` and `docs/baseline_architecture.mermaid` detailing the initial single-region footprint.

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> Analyze the single-region codebase and infrastructure templates in Lab1/ce-sample-hr-vacation. Create two documentation artifacts in the docs/ folder:
> 1. docs/baseline_summary.md: Documenting all Google Cloud components (Cloud Run, Cloud SQL, Firestore, VPC), their service dependencies, and single-region SPOF risks.
> 2. docs/baseline_architecture.mermaid: A Mermaid flowchart representing the initial single-region application topology.
> ```

---

### Step 2: Analyze Customer Requirements & Create Target Architecture Blueprint
Ingest `docs/customer_requirements.md` and extract Cymbal Group's resiliency directives. Generate `docs/updated_summary.md` and `docs/updated_architecture.mermaid`.

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> Read docs/customer_requirements.md. Synthesize the latency, availability, caching, and failover requirements from the customer meeting transcript into:
> 1. docs/updated_summary.md: Outlining enhancements including cross-region Cloud SQL replica, multi-region Firestore, Memorystore for Redis caching, and GCLB Anycast routing.
> 2. docs/updated_architecture.mermaid: A Mermaid diagram depicting symmetric Cloud Run deployment across us-central1 and europe-west1 with Anycast global load balancing.
> ```

---

### Step 3: Declarative Infrastructure Modernization (Terraform)
Refactor `terraform/main.tf` to provision foundational VPC networking, Cloud SQL Primary PostgreSQL, Multi-Region Firestore, and a Memorystore for Redis caching instance in `us-central1`. Apply the configuration declaratively.

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> Update terraform/main.tf to include a google_redis_instance resource named "cache" in us-central1 connected to the private VPC network. Configure the Firestore database for multi-region mode (location_id = "nam5"). Initialize and apply the Terraform plan.
> ```

---

### Step 4: Imperative Secondary Region Expansion & Compute Decoupling
Use imperative tool calling with `gcloud` CLI or Google Cloud MCP services to deploy the secondary region infrastructure in `europe-west1`:
1. Cloud SQL PostgreSQL Cross-Region Read Replica (`hr-vacation-sql-db-replica`).
2. Cloud Run Frontend (`hr-vacation-frontend-europe`) and Backend (`hr-vacation-backend-europe`).
3. Global External Application Load Balancer (GCLB) with Serverless NEGs for `us-central1` and `europe-west1`.

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> Execute imperative gcloud CLI commands or MCP tool calls to:
> 1. Provision a Cloud SQL read replica named "hr-vacation-sql-db-replica" in europe-west1 linked to the master instance.
> 2. Deploy Cloud Run frontend and backend services in europe-west1 connected to local DB_READ_HOST environment variables.
> 3. Create serverless NEGs in us-central1 and europe-west1 and register them to a Global Application Load Balancer backend service.
> 4. Record a comparison between declarative IaC and imperative tool calling in docs/imperative_vs_declarative.md.
> ```

---

### Step 5: System Resilience Validation & Failover Verification
Validate the multi-region installation:
1. Verify global Anycast response latency is <50ms for local queries.
2. Simulate a region outage in `us-central1` by disabling the primary NEG backend and verifying automatic failover to `europe-west1`.
3. Run the automated grading suite `bash verify.sh`.

> [!NOTE]
> **AI Pair-Programming Prompt**:
> ```text
> Run curl health probes against the global load balancer endpoint to measure latency. Simulate a regional failure in us-central1 by setting the capacity-scaler of the US serverless NEG to 0.0, confirm zero-downtime failover to europe-west1, and execute bash verify.sh to validate final scoring.
> ```

---

## Verification & Scoring Rubric

| Requirement | Standard | Points |
|---|---|---|
| **Zero Console Policy** | 100% execution via Agentic IDE / CLI / MCP | Pass |
| **Task 1 Baseline Artifacts** | `baseline_summary.md` & `baseline_architecture.mermaid` (LLM Judge ≥80%) | 20 |
| **Task 2 Requirement Analysis** | `updated_summary.md` & `updated_architecture.mermaid` (LLM Judge ≥80%) | 20 |
| **Task 3 Declarative IaC** | Primary region VPC, Cloud SQL, Firestore, Redis created via Terraform | 20 |
| **Task 4 Imperative Expansion** | Secondary region Cloud Run, SQL Replica & GCLB NEGs deployed via CLI | 20 |
| **Task 5 Failover Validation** | Latency <50ms and 100% pass rate on `verify.sh` failover test | 20 |
