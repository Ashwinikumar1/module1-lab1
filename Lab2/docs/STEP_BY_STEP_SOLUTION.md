# Step-by-Step Deployment Guide & Solution Document
**Lab Title**: Module 1 - Phase 4 (Lab Code: 1.4)  
**Target GCP Project**: `alpha-code-461805`  
**Region**: `us-east1`  

---

## Task Summary & Objective
This guide outlines the complete step-by-step process to analyze the customer's AWS environment state file ([aws_environment.json](file:///Users/ashwinikm/Desktop/Project_Elevate/Module1/Lab2/aws_environment.json)), map all AWS resources to Google Cloud Platform equivalents, and deploy the corresponding reference infrastructure code to GCP project `alpha-code-461805`.

---

## Step 1: Analyze the Customer AWS Environment

1. Inspect the loaded `aws_environment.json` file in the lab workspace:
   ```bash
   cat aws_environment.json
   ```
2. Identify core infrastructure resources:
   - **VPC**: CIDR `10.17.0.0/16`
   - **Subnets**: Public Subnets `10.17.0.0/19` (us-east-1a) & `10.17.32.0/19` (us-east-1b)
   - **EKS Cluster**: `adserver1-prd` with Node Group `prd-adserver1-prd-main` (`c5.large` instances, scaling 1 to 6)
   - **KMS Key**: `592c4134-01bd-4ab1-82eb-9c9824529375` (`alias/eks/adserver1-prd`)
   - **S3 Bucket**: `ad-server-frequency-cappi-serverlessdeploymentbuck-ejatrrd0o9w5`

---

## Step 2: Configure GCP Target Environment

1. Set the target GCP project in your terminal:
   ```bash
   gcloud config set project alpha-code-461805
   ```
2. Enable required GCP APIs:
   ```bash
   gcloud services enable \
     compute.googleapis.com \
     container.googleapis.com \
     cloudkms.googleapis.com \
     storage.googleapis.com \
     iam.googleapis.com
   ```

---

## Step 3: Terraform Code Setup ([main.tf](file:///Users/ashwinikm/Desktop/Project_Elevate/Module1/Lab2/main.tf))

Review the created Terraform code mapping AWS to GCP:

- **Network**: `google_compute_network` and `google_compute_subnetwork` with secondary IP ranges for Kubernetes Pods and Services.
- **Security/Encryption**: `google_kms_key_ring` & `google_kms_crypto_key` for Application-layer secret encryption.
- **Identity**: Dedicated `google_service_account` for GKE Node Pool with minimal IAM roles (`roles/container.nodeServiceAccount`, `roles/logging.logWriter`, etc.).
- **Compute (GKE)**: `google_container_cluster` (GKE Standard) paired with `google_container_node_pool` using `c2-standard-4` compute-optimized instances (matching `c5.large`).
- **Object Storage**: Uniform access `google_storage_bucket` encrypted with the Cloud KMS key.

---

## Step 4: Execute Deployment Commands

1. Initialize Terraform working directory:
   ```bash
   terraform init
   ```
2. Generate and review deployment execution plan:
   ```bash
   terraform plan -var="gcp_project_id=alpha-code-461805"
   ```
3. Apply changes to deploy infrastructure to GCP:
   ```bash
   terraform apply -var="gcp_project_id=alpha-code-461805" -auto-approve
   ```

---

## Step 5: Verify Deployment in GCP

1. **Verify GKE Cluster**:
   ```bash
   gcloud container clusters list --project=alpha-code-461805 --zone=us-east1
   ```
2. **Verify VPC Network & Subnets**:
   ```bash
   gcloud compute networks subnets list --project=alpha-code-461805 --network=adserver1-prd-vpc
   ```
3. **Verify Cloud Storage Bucket**:
   ```bash
   gcloud storage buckets list --project=alpha-code-461805
   ```
4. **Verify Cloud KMS Key Ring**:
   ```bash
   gcloud kms keys list --location=us-east1 --keyring=adserver1-prd-keyring --project=alpha-code-461805
   ```

---

## Step 6: Generate Executive Business Proposal via Migration Center

1. Open **Google Cloud Migration Center** in GCP Console.
2. Select **Import Asset Data** and upload `aws_environment.json`.
3. Select **Generate Proposal with AI**, specify target `alpha-code-461805` and export the executive report.
