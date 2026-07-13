# Lab 2: Enterprise AWS to GCP Reference Infrastructure Migration

**Module**: Module 1 - Phase 4 (Lab Code: 1.4)  
**Target Platform**: Google Cloud Platform (Altostrat Organization)  
**Primary Region**: `us-east1`  

---

## 📖 Overview & Problem Statement

In this lab, you assume the role of a Cloud Solutions Architect assisting **Cymbal Group** in migrating their core **AdServer Production Workload** (`adserver1-prd`) from AWS to Google Cloud Platform. 

You are provided with the customer's production AWS environment export file (`data/aws_environment.json`). Your mission is to map all core infrastructure components to GCP native equivalents, author production-ready Terraform code (`terraform/main.tf`) complying with strict **Altostrat Organization Security Policies**, deploy the infrastructure, and validate the deployment using an automated test framework (`terraform/verify.sh`).

---

## 🎯 What You Will Learn

- **AWS to GCP Architecture Translation**: Map AWS VPC, EKS Cluster, KMS Keys, S3 Buckets, and IAM Roles to GCP VPC Subnetworks, GKE Standard Clusters, Cloud KMS, GCS, and GCP IAM.
- **Enterprise Security Policy Enforcement**:
  - Resolve `constraints/compute.vmExternalIpAccess` by configuring private GKE clusters (`enable_private_nodes = true`).
  - Resolve `constraints/compute.requireShieldedVm` by configuring Shielded VM instance specs with Secure Boot (`enable_secure_boot = true`).
  - Configure Service Agent KMS permissions (`roles/cloudkms.cryptoKeyEncrypterDecrypter`) for GKE and Cloud Storage.
- **Infrastructure Automation & Validation**: Initialize, plan, and apply Terraform templates, and run automated verification scoring scripts.

---

## 📂 Lab 2 Document Reference Guide

| Document | File Path | Description & Purpose |
| :--- | :--- | :--- |
| 🧑‍🎓 **Student Lab Execution Guide** | **[docs/STUDENT_LAB_GUIDE.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab2/docs/STUDENT_LAB_GUIDE.md)** | **START HERE**. Primary step-by-step student instructions, permission checklist, and troubleshooting table. |
| 📝 **Step-by-Step Solution Document** | **[docs/STEP_BY_STEP_SOLUTION.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab2/docs/STEP_BY_STEP_SOLUTION.md)** | Complete technical step-by-step walkthrough detailing resource mappings and commands. |
| 📊 **Deployment & Evaluation Report** | **[docs/lab_deployment_solution_report.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab2/docs/lab_deployment_solution_report.md)** | Summary report detailing architecture mapping, IAM role matrices, and Org Policy compliance. |
| 🔍 **AWS to GCP Technical Analysis** | **[docs/aws_to_gcp_migration_analysis.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab2/docs/aws_to_gcp_migration_analysis.md)** | Technical comparison breakdown of the source AWS infrastructure and target GCP architecture. |
| 💼 **Value Proposition & TCO Report** | **[docs/gcp_value_proposition_analysis.md](file:///Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab2/docs/gcp_value_proposition_analysis.md)** | Executive proposal highlighting cost savings, latency improvements, and DevOps efficiency gains. |

---

## 🛠️ Lab 2 File Taxonomy

- 📁 **`data/`**:
  - `aws_environment.json`: Parsed AWS state file containing VPC, EKS, KMS, and S3 configuration.
  - `aws_production.json`: Secondary reference dataset.
- 📁 **`terraform/`**:
  - `main.tf`: Org-policy compliant Terraform code for VPC, Subnets, KMS, Service Accounts, GKE Cluster, Node Pool, and Storage Bucket.
  - `deploy.sh`: Automated execution script for setting GCP active project, enabling APIs, and running terraform apply.
  - `verify.sh`: Automated 5-step verification test suite for scoring lab success.

---

## ⚡ Quickstart Commands

```bash
# 1. Navigate to Lab 2 Terraform directory
cd Lab2/terraform

# 2. Set GCP Project ID
export PROJECT_ID="YOUR_PROJECT_ID" # e.g. alpha-code-461805
gcloud config set project "${PROJECT_ID}"

# 3. Initialize & Apply Terraform
terraform init
terraform apply -var="gcp_project_id=${PROJECT_ID}" -var="gcp_region=us-east1" -auto-approve

# 4. Run Verification Suite
bash verify.sh
```
