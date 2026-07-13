#!/bin/bash
set -e

PROJECT_ID="alpha-code-461805"
REGION="us-east1"

echo "=========================================================="
echo " Starting GCP Infrastructure Deployment for AdServer"
echo " Target Project: ${PROJECT_ID}"
echo " Region:         ${REGION}"
echo "=========================================================="

echo "[1/4] Setting GCP Active Project..."
gcloud config set project "${PROJECT_ID}"

echo "[2/4] Enabling Required GCP APIs..."
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  cloudkms.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  artifactregistry.googleapis.com

echo "[3/4] Initializing Terraform..."
terraform init

echo "[4/4] Applying Terraform Configuration..."
terraform apply -var="gcp_project_id=${PROJECT_ID}" -var="gcp_region=${REGION}" -auto-approve

echo "=========================================================="
echo " Deployment Successfully Completed!"
echo "=========================================================="
