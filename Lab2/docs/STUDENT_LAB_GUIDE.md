# Lab 2: AWS-to-GCP Enterprise Reference Migration via Agentic AI Tooling

**Lab Title**: Lab 2: AWS-to-GCP Enterprise Reference Migration  
**Lab Code**: 1.4  
**Lab Type**: **Challenge Lab** (Independent skill application; minimal step-by-step instructions)  
**Intended Learner Profile**: Practice CEs, Platform CEs (incl. Partner Advisors), Outcome CEs, GCC Engineers  
**Organization Domain**: `altostrat.com`  

---

## 🏢 Challenge Scenario & Context

You are a Lead Platform Cloud Engineer consulting for the **AdServer Production Migration Team** at **Cymbal Group**.

### Corporate Context & Demo Brand Ecosystem
**Cymbal Group** is a global conglomerate operating a diverse multi-brand ecosystem spanning three core business verticals:
* 🛒 **Retail**: **Cymbal Direct**, **Cymbal Shops**, and **Cymbal Superstore**
* 🏥 **Healthcare**: **Cymbal Labs** and **Cymbal Health**
* 🏦 **Financial Services & Insurance (FSI)**: **Cymbal Bank**, **Cymbal Investments**, **Cymbal Fintech**, and **Cymbal Insurance**

Your consulting engagement focuses directly on **Cymbal Direct** and **Cymbal Shops**—the flagship e-commerce and retail advertising ecosystem responsible for serving real-time targeted promotions, personalized product ads, and dynamic search monetization to millions of active retail shoppers across global storefronts.

### Problem Identification & Migration Imperative
Cymbal Direct's core high-throughput ad-serving backend platform (`adserver1-prd`) currently runs on legacy Amazon Web Services (AWS) infrastructure. As digital retail demand rapidly scales across Cymbal Shops and Cymbal Superstore, the engineering leadership faces three critical operational bottlenecks on AWS:
1. **Security & Governance Non-Compliance**: The legacy AWS topology uses public cluster nodes and un-restricted key policies that violate strict Zero-Trust governance mandates. Under the corporate **Altostrat Organization** security standards, all production container workloads must enforce absolute network isolation (private GKE nodes only), hardware-rooted boot integrity (Shielded VMs with Secure Boot enabled), and service-agent restricted encryption key bindings.
2. **High Operating Costs & Fragmented IAM**: Running non-optimized EC2 instances (`c5.large`) and separate AWS KMS access controls without centralized cloud management increases operational overhead and inflates monthly TCO.
3. **Container Scalability & Security Risks**: The existing AWS EKS cluster (`adserver1-prd`) lacks the automated node protection and zero-trust perimeter needed to securely handle peak traffic during global sales campaigns without exposing backend data stores.

To eliminate these risks, Cymbal Group leadership has mandated a complete platform modernization to **Google Cloud Platform (GCP)** to achieve lower ad latency, unified Cloud KMS protection, mandatory Zero-Trust infrastructure security, and cost optimization.

Over email, the customer engineering team has provided a complete JSON export of their active AWS environment (`aws_environment.json`), which has been loaded into your lab environment at `Lab2/data/aws_environment.json`.

---

## 🎯 Lab Summary & Learning Objectives

In this **Challenge Lab**, you will master the use of **Agentic AI tools** (such as VS Code Antigravity IDE, Antigravity CLI, Google Agent Skills, and MCP) to accelerate enterprise cloud migration workflows. 

### Integrated Learning Objectives:
Throughout this lab, you will combine and execute the following core learning objectives within the Cymbal Group migration storyline:
1. **Leverage Agentic AI Tools for AWS Discovery**: Prompt AI subagents to parse `Lab2/data/aws_environment.json` and extract legacy AWS primitives (VPC `10.17.0.0/16`, EC2 `c5.large`, EKS Cluster `adserver1-prd`, S3 deployment buckets, and KMS keys).
2. **Translate Cross-Cloud Architecture & Produce Deliverables**: Use natural language and Agentic tools to map legacy AWS primitives to GCP native equivalents, generate logical "As-Is" vs. "To-Be" architecture diagrams, and compile TCO value proposition reports.
3. **Generate Reference Set of Org-Policy Compliant GCP Terraform Code**: Produce modular Terraform configuration in `Lab2/terraform/` that strictly satisfies **Altostrat Organization Security Policies**:
   - `constraints/compute.vmExternalIpAccess` (Mandatory private GKE cluster nodes via `enable_private_nodes = true`).
   - `constraints/compute.requireShieldedVm` (Mandatory Secure Boot via `enable_secure_boot = true`).
   - Service Agent Cloud KMS IAM role bindings (`roles/cloudkms.cryptoKeyEncrypterDecrypter`) for GKE and GCS.
4. **Deploy GCP Reference Infrastructure & Pass Lab Verification**: Provision the target GCP infrastructure using Terraform. Validation and scoring are conducted automatically by the lab platform runner via `verify.sh` to evaluate 100/100 points across 5 checkpoints.
5. **Formulate Tailored Executive Proposal via Migration Center AI**: Utilize GCP Console Migration Center AI features and Agentic prompts to synthesize a customized business proposal for Cymbal Group leadership.

---

## 📋 General Overview of Lab Steps

Learners will follow a structured 5-task workflow to complete the migration project:

```
[Task 1: AI AWS Discovery] ➔ [Task 2: Technical Artifacts] ➔ [Task 3: Generate Terraform IaC] ➔ [Task 4: Deploy & Lab Verification] ➔ [Task 5: Migration Center AI Proposal]
```

1. **Task 1: Analyze AWS Infrastructure Baseline via Agentic AI**
   - Inspect `Lab2/data/aws_environment.json` using AI prompts.
   - Extract VPC CIDR blocks, EKS cluster configurations, compute node specs, and storage/KMS keys.
2. **Task 2: Generate Cross-Cloud Mapping & Technical Architecture Artifacts**
   - Create standard AWS-to-GCP technical comparison matrices.
   - Produce GFM/Mermaid logical architecture diagrams illustrating legacy AWS "As-Is" vs target GCP "To-Be" perimeters.
   - Draft executive value proposition and TCO analysis reports.
3. **Task 3: Generate Reference Set of Org-Policy Compliant GCP Terraform Code**
   - Author production-ready Terraform configurations (`main.tf`, `variables.tf`) in `Lab2/terraform/`.
   - Enforce Private GKE Nodes, Shielded VM Secure Boot, and KMS IAM service agent grants meeting Altostrat Org constraints.
4. **Task 4: Deploy Reference GCP Architecture to Google Cloud**
   - Initialize and apply the generated Terraform plan (`terraform init`, `terraform apply`).
   - **Lab Verification & Scoring**: Automated verification script (`verify.sh`) is executed by the lab platform creator to validate deployed GCP infrastructure and assign 100 scoring points.
5. **Task 5: Synthesize Tailored Business Proposal via Migration Center AI**
   - Access GCP Console Migration Center and invoke AI prompt capabilities to generate an executive migration proposal for Cymbal Group leadership.

---

## 🛡️ Altostrat Organization Security Constraints Notice

Because your project operates under the **Altostrat Organization**, security policies are strictly enforced. Your generated Terraform configuration MUST satisfy the following org policies:

1. **`constraints/compute.vmExternalIpAccess` (No Public VM IPs)**:
   - GKE nodes cannot have public IP addresses. You must enable `private_cluster_config` with `enable_private_nodes = true`.
2. **`constraints/compute.requireShieldedVm` (Shielded Instances)**:
   - All compute instances and GKE node pools must have `shielded_instance_config` with `enable_secure_boot = true` and `enable_integrity_monitoring = true`.
3. **Cloud KMS Service Agent IAM Grants**:
   - GKE (`service-<PROJECT_NUMBER>@container-engine-robot.iam.gserviceaccount.com`) and Cloud Storage (`service-<PROJECT_NUMBER>@gs-project-accounts.iam.gserviceaccount.com`) service agents must be explicitly granted `roles/cloudkms.cryptoKeyEncrypterDecrypter` on Cloud KMS keys prior to resource creation.

---

## ⚡ High-Level Challenge Task List (5 Core Tasks)

---

### Task 1: Analyze AWS Infrastructure State via Agentic AI

Use your Agentic AI IDE or CLI to inspect and summarize `Lab2/data/aws_environment.json`.

#### Example AI Prompt:
> *"Analyze `Lab2/data/aws_environment.json`. Identify all AWS compute, network, container, storage, and key management resources. Extract VPC CIDR blocks, instance machine types, EKS cluster names, and S3 bucket identifiers."*

#### Extracted AWS Environment Baseline:
* **VPC Network**: AWS VPC (`10.17.0.0/16`) across two Availability Zones (`us-east-1a`, `us-east-1b`).
* **Container Cluster**: AWS EKS Cluster (`adserver1-prd`) running node pool `c5.large`.
* **Storage & Encryption**: AWS S3 deployment bucket & AWS KMS Customer Managed Key.

---

### Task 2: Generate Cross-Cloud Mapping & Technical Deliverables

Use your Agentic AI assistant to create standard technical comparison documents and diagrams for Cymbal Group leadership.

#### Required Deliverable Documents:
1. **Resource Group Mapping Comparison**: Document a comprehensive comparison mapping each AWS resource group primitive to its GCP equivalent:
   - AWS VPC ➔ GCP Private VPC (`google_compute_network`) & Custom Subnets (`google_compute_subnetwork`).
   - AWS EKS Cluster ➔ GCP GKE Standard Private Cluster (`google_container_cluster`).
   - AWS EC2 `c5.large` ➔ GCP Compute Engine `c2-standard-4` / Node Pool.
   - AWS S3 Bucket ➔ GCP Cloud Storage Bucket (`google_storage_bucket`) with Uniform Bucket-Level Access.
   - AWS KMS Key ➔ GCP Cloud KMS Key Ring & Crypto Key (`google_kms_crypto_key`).
2. **Logical Architecture Diagrams**: Produce logical architectural diagrams illustrating both the legacy AWS "As-Is" topology and the modern GCP "To-Be" architecture.
3. **Value Proposition & TCO Analysis**: Draft an executive document detailing why the proposed GCP solution provides superior zero-trust security (Shielded VMs, Private GKE), lower latency, and greater cost effectiveness.

---

### Task 3: Generate Reference Set of Org-Policy Compliant GCP Terraform Code

Using your Agentic AI assistant, generate a complete reference set of production-grade, modular Terraform code in `Lab2/terraform/` that complies with all Altostrat organization security rules.

#### Infrastructure Specifications to Include in `main.tf`:
- **VPC & Subnets**: Custom VPC network with private subnets in `us-east1`.
- **Private GKE Cluster**: Cluster `adserver1-prd` with `private_cluster_config { enable_private_nodes = true }`.
- **Shielded VM Node Pool**: Node pool `prd-adserver1-prd-main` configured with `shielded_instance_config { enable_secure_boot = true, enable_integrity_monitoring = true }`.
- **KMS Encrypted Storage**: Bucket `ad-server-frequency-cappi-deployment-${PROJECT_ID}` with uniform access and Cloud KMS customer-managed key encryption.
- **Service Agent IAM Bindings**: Explicit `google_kms_crypto_key_iam_member` resources granting `roles/cloudkms.cryptoKeyEncrypterDecrypter` to GKE and GCS service agents.

---

### Task 4: Deploy Reference GCP Infrastructure to Google Cloud

Deploy the generated GCP reference configuration to Google Cloud.

#### Step 4.1: Initialize & Configure Environment
```bash
cd Lab2/terraform
export PROJECT_ID=$(gcloud config get-value project)
gcloud auth application-default login
```

#### Step 4.2: Apply Terraform Code
```bash
terraform init
terraform plan -var="gcp_project_id=${PROJECT_ID}" -var="gcp_region=us-east1"
terraform apply -var="gcp_project_id=${PROJECT_ID}" -var="gcp_region=us-east1" -auto-approve
```
*Note: Provisioning the private GKE cluster takes approximately 8-10 minutes.*

#### Step 4.3: Automated Lab Verification & Scoring (Lab Creator Verification)
Once deployment is complete, the automated lab grading platform (lab creator runner) executes `verify.sh` to validate the environment and assign lab points:

```bash
# Executed by Lab Creator / Automated Grading System
cd Lab2/terraform
bash verify.sh
```

##### Verification Checkpoints (100 Points Total):
- [ ] **[1/5] GKE Cluster Status**: `adserver1-prd` in status `RUNNING` (20 Points).
- [ ] **[2/5] GKE Node Pool**: `prd-adserver1-prd-main` with Shielded VM Secure Boot enabled (20 Points).
- [ ] **[3/5] VPC Subnets**: Subnets `adserver1-prd-subnet-a` & `subnet-b` active in private network (20 Points).
- [ ] **[4/5] Cloud Storage**: Bucket `ad-server-frequency-cappi-deployment-${PROJECT_ID}` with Uniform Access and KMS Encryption enabled (20 Points).
- [ ] **[5/5] Cloud KMS**: Key `adserver1-prd-gke-key` in state `ENABLED` with service account bindings (20 Points).

---

### Task 5: Generate Tailored Proposal via Migration Center AI

Use GCP Console Migration Center AI tools or Agentic prompts to generate a custom executive business proposal for Cymbal Group leadership:
1. Navigate to **GCP Console ➔ Migration Center**.
2. Run AI proposal generator or prompt Agentic assistant:
   > *"Generate an executive migration business proposal for Cymbal Group detailing modernizing AWS adserver1-prd to GCP GKE Private Cluster with Cloud KMS encryption."*

---

## 🛠️ Student Troubleshooting Guide

| Issue / Error | Cause | Remediation |
| :--- | :--- | :--- |
| **`403 IAM_PERMISSION_DENIED`** | Account lacks GCP project permissions or wrong active account | Run `gcloud config set account <your-email>@altostrat.com` and ensure project Owner/Editor role is assigned. |
| **`MISSING_IAM_PERMISSIONS_ON_CRYPTO_KEY`** | Service agents missing KMS Encrypter/Decrypter permissions | Ensure `google_kms_crypto_key_iam_member` resources exist in `main.tf` and `depends_on` is specified for GKE and GCS. |
| **`Constraint constraints/compute.vmExternalIpAccess violated`** | Public IP assignment blocked by Altostrat policy | Add `private_cluster_config { enable_private_nodes = true }` in `main.tf`. |
| **`Constraint constraints/compute.requireShieldedVm violated`** | Secure Boot not enabled on VM/Node Pool | Add `shielded_instance_config { enable_secure_boot = true }` in `node_config`. |

---
*End of Lab 2 Challenge Lab Guide.*

