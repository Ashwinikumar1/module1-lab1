# Helper data source to query active gcloud settings dynamically
data "external" "gcloud" {
  program = ["bash", "-c", "echo \"{\\\"project\\\": \\\"$(gcloud config get-value project 2>/dev/null)\\\", \\\"account\\\": \\\"$(gcloud config get-value account 2>/dev/null)\\\"}\""]
}

locals {
  # Fallback logic: Use explicit variables if set; otherwise, use auto-detected settings from gcloud
  project_id    = var.project_id != "" ? var.project_id : data.external.gcloud.result.project
  student_email = var.student_email != "" ? var.student_email : data.external.gcloud.result.account
}
