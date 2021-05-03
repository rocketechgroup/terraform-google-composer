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

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = var.project_id
  network_name = var.network
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name   = "${var.company_name}-app-ew2-dev-subnet"
      subnet_ip     = "10.10.0.0/20"
      subnet_region = "europe-west2"
    }
  ]

  secondary_ranges = {
    "${var.company_name}-app-ew2-dev-subnet" = [
      {
        range_name    = "composer-pods-1"
        ip_cidr_range = "10.11.0.0/21"
      },
      {
        range_name    = "composer-services-1"
        ip_cidr_range = "10.12.0.0/24"
      }
    ]
  }

  # See https://cloud.google.com/composer/docs/how-to/managing/configuring-private-ip for more details
  firewall_rules = [
    {
      name        = "composer-nodes-hc-ingress"
      direction   = "INGRESS"
      description = "Allow ingress from GCP Health Checks"
      ranges      = ["130.211.0.0/22", "35.191.0.0/16"]

      allow = [{
        protocol = "tcp"
        ports    = ["80", "443"]
      }]

      target_tags = ["composer-nodes"]
    },
    {
      name        = "composer-nodes-hc-egress"
      direction   = "EGRESS"
      description = "Allow egress from GKE Node IP range to GCP Health Checks"
      ranges      = ["130.211.0.0/22", "35.191.0.0/16"]

      allow = [{
        protocol = "tcp"
        ports    = ["80", "443"]
      }]

      target_tags = ["composer-nodes"]
    },
    {
      name        = "composer-nodes-master-egress"
      direction   = "EGRESS"
      description = "Allow egress from GKE Node IP range to GKE Master IP range"
      ranges      = ["10.13.0.0/28"]

      allow = [{
        protocol = "tcp"
        ports    = []
      }]

      target_tags = ["composer-nodes"]
    },
    {
      name        = "composer-nodes-web-egress"
      direction   = "EGRESS"
      description = "Allow egress from GKE Node IP range to Web server IP range"
      ranges      = ["10.13.1.0/28"]

      allow = [{
        protocol = "tcp"
        ports    = ["3306", "3307"]
      }]

      target_tags = ["composer-nodes"]
    },
    {
      name        = "composer-nodes-composer-nodes-egress"
      direction   = "EGRESS"
      description = "Allow egress from GKE Node IP range to GKE Node IP range, all ports"
      ranges      = ["10.10.0.0/20"]

      allow = [{
        protocol = "tcp"
        ports    = []
      }]

      target_tags = ["composer-nodes"]
    },
    {
      name        = "composer-nodes-any-egress"
      direction   = "EGRESS"
      description = "Allow egress from GKE Node IP range to any destination (0.0.0.0/0)"
      ranges      = ["0.0.0.0/0"]

      allow = [
        {
          protocol = "tcp"
          ports    = ["53"]
        },
        {
          protocol = "udp"
          ports    = ["53"]
        }
      ]

      target_tags = ["composer-nodes"]
    }
  ]
}