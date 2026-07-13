# Copyright 2023 Google LLC All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

locals {
  # Extract username prefix (everything before @) from student's email
  student_username = split("@", local.student_email)[0]

  # Sanitize: convert to lowercase and replace any non-alphanumeric chars with hyphens
  student_name_clean = replace(lower(local.student_username), "/[^a-z0-9_-]/", "-")

  # Define the dynamic bucket name
  bucket_name = "${local.project_id}-${local.student_name_clean}-cloudbuild-hr"
}

resource "google_storage_bucket" "gcs-cloud-build" {
  name                        = local.bucket_name
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}