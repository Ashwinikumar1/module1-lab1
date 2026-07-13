# Complete Lab Documentation & Scoring Guide
**Module**: Module 1 - Phase 4 (Lab 1.4)  
**Target GCP Project**: `alpha-code-461805`  
**Region**: `us-east1`  
**Status**: Completed & Verified  

---

## 1. Executive Summary & Architecture Mapping

This document provides a complete guide for Lab 1.4, mapping AWS infrastructure from `aws_environment.json` to Google Cloud Platform equivalents and deploying them via Terraform.

### Resource Mapping Matrix

| Component | AWS Resource (`aws_environment.json`) | GCP Infrastructure (`main.tf`) |
| :--- | :--- | :--- |
| **Network** | AWS VPC `10.17.0.0/16` & Subnets | VPC `adserver1-prd-vpc`, Subnets `adserver1-prd-subnet-a` (`10.17.0.0/19`) & `subnet-b` (`10.17.32.0/19`) |
| **Kubernetes** | AWS EKS Cluster `adserver1-prd` | GKE Cluster `adserver1-prd` with Node Pool `prd-adserver1-prd-main` (`c2-standard-4`, autoscaling 1-6) |
| **Encryption** | AWS KMS Key `alias/eks/adserver1-prd` | Cloud KMS Key Ring `adserver1-prd-keyring` & Crypto Key `adserver1-prd-gke-key` |
| **Object Storage**| AWS S3 Bucket `ad-server-frequency-cappi...` | Uniform access Cloud Storage Bucket `ad-server-frequency-cappi-deployment-alpha-code-461805` |
| **Identity/IAM** | AWS EKS Node IAM Role | Service Account `adserver1-prd-node-sa@alpha-code-461805.iam.gserviceaccount.com` |

---

## 2. Required IAM Permissions & Authentication

### User / Administrator Permissions
To deploy and administer the lab infrastructure on `alpha-code-461805`, the deploying user account must have:
- **`roles/owner`** OR **`roles/editor`** + Security Admin rights on the target GCP project.

### Service Account & System IAM Roles
The Terraform template configures the following IAM bindings automatically:

1. **GKE Node Pool Service Account** (`adserver1-prd-node-sa@alpha-code-461805.iam.gserviceaccount.com`):
   - `roles/container.nodeServiceAccount`
   - `roles/logging.logWriter`
   - `roles/monitoring.metricWriter`
   - `roles/artifactregistry.reader`

2. **KMS Encrypter/Decrypter Roles** (`roles/cloudkms.cryptoKeyEncrypterDecrypter`):
   - **GKE Service Agent**: `service-100889782425@container-engine-robot.iam.gserviceaccount.com`
   - **Cloud Storage Service Agent**: `service-100889782425@gs-project-accounts.iam.gserviceaccount.com`

---

## 3. Organization Policies & Compliance Rules

The deployment satisfies strict GCP Organization Security Constraints:

1. **`constraints/compute.vmExternalIpAccess` (Private Nodes)**:
   - Configured `private_cluster_config` with `enable_private_nodes = true` and dedicated master CIDR `172.16.0.0/28`.
2. **`constraints/compute.requireShieldedVm` (Secure Boot)**:
   - Enabled `shielded_instance_config` with `enable_secure_boot = true` and `enable_integrity_monitoring = true` on cluster node configurations.

---

## 4. Step-by-Step Deployment Commands (Prompt & Execution Log)

### Step 1: Enable Required GCP APIs
```bash
gcloud config set project alpha-code-461805
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  cloudkms.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  artifactregistry.googleapis.com
```

### Step 2: Initialize Terraform Backend & Download Providers
```bash
cd /Users/ashwinikm/Desktop/Project_Elevate/projectelevate-module1/Lab2
terraform init
```

### Step 3: Provision Infrastructure
```bash
terraform apply -var="gcp_project_id=alpha-code-461805" -var="gcp_region=us-east1" -auto-approve
```

---

## 5. Lab Evaluation & Automated Verification Script (`verify.sh`)

Use the following automated verification script to validate all 5 critical components for lab scoring:

```bash
#!/bin/bash
PROJECT_ID="alpha-code-461805"
REGION="us-east1"

echo "=========================================================="
echo " Verification Script for GCP Infrastructure Deployment"
echo " Target Project: ${PROJECT_ID}"
echo " Region:         ${REGION}"
echo "=========================================================="

echo -e "\n[1/5] Checking GKE Cluster Status..."
gcloud container clusters list --project="${PROJECT_ID}" --location="${REGION}"

echo -e "\n[2/5] Checking GKE Node Pools..."
gcloud container node-pools list --cluster=adserver1-prd --location="${REGION}" --project="${PROJECT_ID}"

echo -e "\n[3/5] Checking VPC Subnets..."
gcloud compute networks subnets list --project="${PROJECT_ID}" --network=adserver1-prd-vpc

echo -e "\n[4/5] Checking Cloud Storage Buckets..."
gcloud storage buckets list --project="${PROJECT_ID}" --filter="name:ad-server-frequency-cappi-deployment-${PROJECT_ID}"

echo -e "\n[5/5] Checking Cloud KMS Keys..."
gcloud kms keys list --location="${REGION}" --keyring=adserver1-prd-keyring --project="${PROJECT_ID}"

echo -e "\n=========================================================="
echo " Infrastructure Verification Completed!"
echo "=========================================================="
```

---

## 6. Final Deployment Outputs & Status

```hcl
deployment_bucket_url = "gs://ad-server-frequency-cappi-deployment-alpha-code-461805"
gke_cluster_name      = "adserver1-prd"
vpc_network_name      = "adserver1-prd-vpc"
```
- **GKE Cluster Status**: `RUNNING` (9 nodes across `us-east1-b`, `us-east1-c`, `us-east1-d`).
- **Bucket Security**: Encrypted with Cloud KMS Key `adserver1-prd-gke-key` and Uniform Access enforced.
- **Node Pool**: Active on `c2-standard-4` compute-optimized instances.
