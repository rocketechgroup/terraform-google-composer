/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/******************************************
  Provider configuration
 *****************************************/
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.65.0"
    }

    google-beta = {
      source  = "hashicorp/google"
      version = "3.65.0"
    }
  }
}

module "simple-composer-environment" {
  source = "../../modules/create_environment"

  project_id               = var.project_id
  composer_env_name        = var.composer_env_name
  region                   = var.region
  composer_service_account = var.composer_service_account
  network                  = var.network
  subnetwork               = var.subnetwork
  use_ip_aliases           = true
  tags                     = ["composer-nodes"]

  enable_private_endpoint          = true
  pod_ip_allocation_range_name     = var.pod_ip_allocation_range_name
  service_ip_allocation_range_name = var.service_ip_allocation_range_name
  master_ipv4_cidr                 = "10.13.0.0/28"
  web_server_ipv4_cidr             = "10.13.1.0/28"
  cloud_sql_ipv4_cidr              = "10.13.2.0/24"

  machine_type  = "n1-standard-1"
  zone          = "europe-west2-b"
  image_version = "composer-1.16.2-airflow-1.10.15"
}
