# Student Lab Guide: AWS to GCP Infrastructure Migration & Deployment

**Module**: Module 1 - Phase 4 (Lab Code: 1.4)  
**Organization Domain**: `altostrat.com`  
**Target GCP Project Variable**: `${PROJECT_ID}` (e.g., `alpha-code-461805` or your assigned Altostrat GCP Project ID)  
**Target Region**: `us-east1`  

---

## 🎯 Lab Objectives

In this hands-on lab, you will:
1. Analyze a customer's production AWS environment configuration (`aws_environment.json`).
2. Map AWS infrastructure components (VPC, EKS Cluster, KMS Keys, S3 Bucket, IAM Roles) to equivalent GCP services.
3. Configure Terraform infrastructure-as-code (`main.tf`) that adheres strictly to **Altostrat Organization Security Policies**.
4. Deploy GCP infrastructure and verify deployment using an automated verification test script (`verify.sh`).

---

## 🔐 Prerequisites & Permission Checklist

Before starting, ensure your Altostrat student account has the required access:

- [ ] **Altostrat Account Credentials**: Logged in as `<your-user>@<domain>.altostrat.com`.
- [ ] **IAM Project Role**: **`roles/owner`** or **`roles/editor`** assigned on your target GCP project.
- [ ] **CLI Authentication**: Authorized via `gcloud auth login` and `gcloud auth application-default login`.

---

## 🏢 Organization Security Constraints Notice

Because your project operates under the **Altostrat Organization**, security policies are strictly enforced. Your Terraform configuration MUST satisfy the following org policies:

1. **`constraints/compute.vmExternalIpAccess` (No Public VM IPs)**:
   - GKE nodes cannot have public IP addresses. You must enable `private_cluster_config` with `enable_private_nodes = true`.
2. **`constraints/compute.requireShieldedVm` (Shielded Instances)**:
   - All compute instances and GKE node pools must have `shielded_instance_config` with `enable_secure_boot = true` and `enable_integrity_monitoring = true`.
3. **Cloud KMS Service Agent IAM Grants**:
   - GKE (`service-<PROJECT_NUMBER>@container-engine-robot.iam.gserviceaccount.com`) and Cloud Storage (`service-<PROJECT_NUMBER>@gs-project-accounts.iam.gserviceaccount.com`) service agents must be explicitly granted `roles/cloudkms.cryptoKeyEncrypterDecrypter` on Cloud KMS keys prior to resource creation.

---

## 📋 Step-by-Step Lab Execution Guide

### Task 1: Environment Setup & GCP Authentication

1. Open your terminal and navigate to the Terraform directory:
   ```bash
   cd /Users/ashwinikm/Desktop/Project_Elevate/Module1/Lab2/terraform
   ```

2. Set your assigned Altostrat GCP Project ID:
   ```bash
   export PROJECT_ID="alpha-code-461805" # Replace with your assigned Altostrat Project ID if different
   gcloud config set account kmashwini@ashwinikm.altostrat.com
   gcloud config set project "${PROJECT_ID}"
   ```

3. Authenticate Application Default Credentials (ADC) for Terraform:
   ```bash
   gcloud auth application-default login
   ```
   *Follow the on-screen browser prompt to authorize access.*

4. Enable required GCP API services:
   ```bash
   gcloud services enable \
     compute.googleapis.com \
     container.googleapis.com \
     cloudkms.googleapis.com \
     storage.googleapis.com \
     iam.googleapis.com \
     artifactregistry.googleapis.com
   ```

---

### Task 2: Analyze Customer AWS Environment & Review Terraform Code

1. Inspect the customer's AWS environment file in the `data/` folder:
   ```bash
   cat ../data/aws_environment.json
   ```
   *Note the AWS VPC CIDR `10.17.0.0/16`, EKS node pool specs (`c5.large`), KMS Key ARN, and S3 deployment bucket.*

2. Review [main.tf](file:///Users/ashwinikm/Desktop/Project_Elevate/Module1/Lab2/terraform/main.tf) to observe the AWS-to-GCP resource translations:
   - AWS VPC ➔ `google_compute_network` (`adserver1-prd-vpc`) & `google_compute_subnetwork` (`adserver1-prd-subnet-a`)
   - AWS KMS Key ➔ `google_kms_key_ring` & `google_kms_crypto_key` (`adserver1-prd-gke-key`)
   - AWS EKS Cluster & Node Pool ➔ `google_container_cluster` (`adserver1-prd`) & `google_container_node_pool` (`prd-adserver1-prd-main`)
   - AWS S3 Bucket ➔ `google_storage_bucket` (`ad-server-frequency-cappi-deployment-${PROJECT_ID}`)

---

### Task 3: Initialize & Deploy Infrastructure via Terraform

1. Ensure you are in the `terraform/` directory:
   ```bash
   cd /Users/ashwinikm/Desktop/Project_Elevate/Module1/Lab2/terraform
   terraform init
   ```

2. Generate and review execution plan:
   ```bash
   terraform plan -var="gcp_project_id=${PROJECT_ID}" -var="gcp_region=us-east1"
   ```

3. Apply changes to provision GCP infrastructure:
   ```bash
   terraform apply -var="gcp_project_id=${PROJECT_ID}" -var="gcp_region=us-east1" -auto-approve
   ```
   *Note: GKE cluster creation typically takes 8-10 minutes.*

---

### Task 4: Verify Deployment & Automated Grading

Run the automated verification script [verify.sh](file:///Users/ashwinikm/Desktop/Project_Elevate/Module1/Lab2/terraform/verify.sh) to test all 5 evaluation checkpoints:

```bash
cd /Users/ashwinikm/Desktop/Project_Elevate/Module1/Lab2/terraform
bash verify.sh
```

**Expected Successful Output Breakdown:**
- **[1/5] GKE Cluster Status**: `adserver1-prd` in status `RUNNING`.
- **[2/5] GKE Node Pool**: `prd-adserver1-prd-main` with machine type `c2-standard-4`.
- **[3/5] VPC Subnets**: Subnets `adserver1-prd-subnet-a` & `subnet-b` active.
- **[4/5] Cloud Storage**: Bucket `ad-server-frequency-cappi-deployment-${PROJECT_ID}` with Uniform Access and KMS Encryption enabled.
- **[5/5] Cloud KMS**: Key `adserver1-prd-gke-key` in state `ENABLED`.

---

## 🛠️ Student Troubleshooting Guide

| Issue / Error | Cause | Remediation |
| :--- | :--- | :--- |
| **`403 IAM_PERMISSION_DENIED`** | Account lacks GCP project permissions or wrong active account | Run `gcloud config set account <your-email>@altostrat.com` and ensure project Owner/Editor role is assigned. |
| **`MISSING_IAM_PERMISSIONS_ON_CRYPTO_KEY`** | Service agents missing KMS Encrypter/Decrypter permissions | Ensure `google_kms_crypto_key_iam_member` resources exist in `main.tf` and `depends_on` is specified for GKE and GCS. |
| **`Constraint constraints/compute.vmExternalIpAccess violated`** | Public IP assignment blocked by Altostrat policy | Add `private_cluster_config { enable_private_nodes = true }` in `main.tf`. |
| **`Constraint constraints/compute.requireShieldedVm violated`** | Secure Boot not enabled on VM/Node Pool | Add `shielded_instance_config { enable_secure_boot = true }` in `node_config`. |
| **`Cannot destroy cluster because deletion_protection is set to true`** | Cluster in tainted state during recreation | Add `deletion_protection = false` to `google_container_cluster` or run `gcloud container clusters delete adserver1-prd --location=us-east1 --quiet`. |
