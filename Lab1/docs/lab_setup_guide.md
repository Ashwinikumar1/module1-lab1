# Lab Creation Team: Step-by-Step Provisioning Guide
**Subsystem: HR Vacation Request Portal (Modular GCP Classroom Environment)**

This guide provides the lab creation team with the end-to-end instructions required to initialize, secure, and troubleshoot the HR Vacation Request subsystem for new student enrollments.

---

## 📋 Prerequisites & Tools Required
The environment requires the following tools installed locally on the provisioning host:
1. **Google Cloud SDK (gcloud CLI)**: Authenticated with the student's project scope.
2. **Terraform CLI**: Recommended version `v1.5.0` or higher (installed via Homebrew: `brew tap hashicorp/tap && brew install terraform`).
3. **Git**: To clone the source repository.

---

## 📥 Step 0: Clone the Repository
To clone the pre-configured codebase containing the streamlined auto-detection settings, specify the `lab-setup` branch when cloning:
```bash
git clone -b lab-setup https://github.com/alanpoole/ce-sample-hr-vacation.git
cd ce-sample-hr-vacation
```

---

## 🛠️ Step 1: Variable Auto-Detection & Configuration
To streamline deployment, the Terraform scripts are configured to **auto-detect** the student's active GCP Project ID and authenticated account email directly from their local `gcloud` context. 

Students do **not** need to declare `project_id` or `student_email` in their `terraform.tfvars` file.

1. Create a `terraform/terraform.tfvars` file to supply remaining environment secrets (like IAP clients if pre-generated):
   ```hcl
   # These can be left empty to generate dynamically
   iap_client_id     = ""
   iap_client_secret = ""
   ```

2. **Auto-Detection HCL Logic**:
   The auto-detection runs a bash command via Terraform's `external` provider under `terraform/locals.tf`:
   ```hcl
   data "external" "gcloud" {
     program = ["bash", "-c", "echo \"{\\\"project\\\": \\\"$(gcloud config get-value project 2>/dev/null)\\\", \\\"account\\\": \\\"$(gcloud config get-value account 2>/dev/null)\\\"}\""]
   }

   locals {
     # Fallback: Use explicit variables if set; otherwise, use gcloud auto-detected values
     project_id    = var.project_id != "" ? var.project_id : data.external.gcloud.result.project
     student_email = var.student_email != "" ? var.student_email : data.external.gcloud.result.account
   }
   ```

---

## 📁 Step 2: Dynamic GCS Bucket Naming (HCL Pattern)
To avoid name collisions on global resources (like Google Cloud Storage buckets), the GCS bucket name is dynamically generated based on the student's email address by parsing the username prefix.

In the student's `terraform/gcs.tf` file, implement this parsing block which references the resolved local auto-detected properties:
```hcl
locals {
  # 1. Extract username prefix (everything before the '@') from the local auto-detected email
  student_username = split("@", local.student_email)[0]

  # 2. Sanitize username: lowercase and replace non-alphanumeric chars with hyphens
  student_name_clean = replace(lower(local.student_username), "/[^a-z0-9_-]/", "-")

  # 3. Define the globally unique bucket name using local project_id
  bucket_name = "${local.project_id}-${local.student_name_clean}-cloudbuild-hr"
}

resource "google_storage_bucket" "gcs-cloud-build" {
  name                        = local.bucket_name
  location                    = var.region
  force_destroy               = true  # Allows clean teardown on lab reset
  uniform_bucket_level_access = true
}
```

---

## 📦 Step 3: Bootstrap Container Images
Before applying Terraform, the Node.js application container images must be built and stored in the Google Artifact Registry repository to provide a valid image target for Cloud Run.

1. Ensure the Artifact Registry repository exists or let Terraform create it. If running manually, execute the Google Cloud Build tasks:
   ```bash
   gcloud builds submit --tag us-central1-docker.pkg.dev/PROJECT_ID/ce-sample-hr-vacation-repo/frontend:latest .
   ```

---

## 🏗️ Step 4: Provision Infrastructure with Terraform
Initialize Terraform and import any pre-existing project-wide resources (like the default Firestore database if already provisioned).

1. Initialize Terraform:
   ```bash
   terraform init
   ```
2. If Firestore default database is already active in the project (common in sandbox environments), import it:
   ```bash
   terraform import google_firestore_database.firestore "(default)"
   ```
3. Deploy the infrastructure:
   ```bash
   terraform apply -auto-approve
   ```

---

## 🔒 Step 5: Secure IAP to Cloud Run Access
For GCLB Identity-Aware Proxy to call your private Cloud Run frontend service, the IAP Service Agent must be provisioned and explicitly granted invocation permissions.

1. **Create the IAP Service Agent** (if not already provisioned):
   ```bash
   gcloud beta services identity create --service=iap.googleapis.com --project=PROJECT_ID
   ```
   *This generates a service account in the format: `service-[PROJECT_NUMBER]@gcp-sa-iap.iam.gserviceaccount.com`.*

2. **Restrict Cloud Run Ingress & Grant Invoker Role**:
   In `terraform/main.tf`, replace any public (`allUsers`) Cloud Run invoker rules with a strict binding for the newly created IAP service account:
   ```hcl
   data "google_project" "project" {}

   resource "google_cloud_run_v2_service_iam_member" "frontend_iap_invoker" {
     name     = google_cloud_run_v2_service.frontend_service.name
     location = google_cloud_run_v2_service.frontend_service.location
     role     = "roles/run.invoker"
     member   = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-iap.iam.gserviceaccount.com"
   }
   ```

---

## 🌐 Step 6: Local DNS Configuration for Students
Because GCLB IAP requires domain-based routing (raw IP addresses are not supported by IAP authentication callbacks), the student must configure their local host database.

1. Run `terraform output` to retrieve the GCLB global IP address.
2. Instruct the student to append the following mapping to their `/etc/hosts` file:
   ```text
   [LOAD_BALANCER_IP] hr-vacation.gcp-lab.internal
   ```
3. Access the portal at: **`https://hr-vacation.gcp-lab.internal`**

---

## 🔍 Troubleshooting & Known Errors

### ❌ Error Code 52: Hostname/SSL Certificate Mismatch
* **Symptom**: User hits the GCLB IP and receives IAP Error Code 52.
* **Cause**: The user visited the raw IP (`34.120.184.191`) instead of the domain `hr-vacation.gcp-lab.internal`, or the self-signed SSL certificate does not list the hostname in its SANs list.
* **Solution**: Ensure the student is navigating to `https://hr-vacation.gcp-lab.internal` with their `/etc/hosts` mapped. Also, verify that the `tls_self_signed_cert` configuration in `main.tf` has the `dns_names` property set correctly:
  ```hcl
  dns_names = ["hr-vacation.gcp-lab.internal"]
  ```

### ❌ "SslCertificate is already being used" apply lock
* **Symptom**: Running `terraform apply` fails when updating the self-signed SSL cert, stating the certificate is in use by another resource.
* **Solution**: Ensure your `google_compute_ssl_certificate` resource uses `name_prefix` and has a `create_before_destroy` lifecycle rule:
  ```hcl
  resource "google_compute_ssl_certificate" "self_signed" {
    name_prefix = "hr-vac-self-signed-"
    private_key = tls_private_key.key.private_key_pem
    certificate = tls_self_signed_cert.cert.cert_pem
    lifecycle {
      create_before_destroy = true
    }
  }
  ```
