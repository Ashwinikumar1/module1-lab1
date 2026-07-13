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
