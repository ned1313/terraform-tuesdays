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

variable "project_id" {
  type        = string
  description = "The project id to deploy Github Runner"
}
variable "region" {
  type        = string
  description = "The GCP region to deploy instances into"
  default     = "us-east4"
}

variable "zone" {
  type        = string
  description = "The GCP zone to deploy instances into"
  default     = "us-east4-b"
}

variable "network_name" {
  type        = string
  description = "Name for the VPC network"
  default     = "gh-runner-network"
}

variable "create_network" {
  type        = bool
  description = "When set to true, VPC,router and NAT will be auto created"
  default     = true
}

variable "subnetwork_project" {
  type        = string
  description = "The ID of the project in which the subnetwork belongs. If it is not provided, the project_id is used."
  default     = ""
}

variable "subnet_ip" {
  type        = string
  description = "IP range for the subnet"
  default     = "10.10.10.0/24"
}
variable "subnet_name" {
  type        = string
  description = "Name for the subnet"
  default     = "gh-runner-subnet"
}

variable "restart_policy" {
  type        = string
  description = "The desired Docker restart policy for the runner image"
  default     = "Always"
}

variable "org_url" {
  type        = string
  description = "Org URL for the Github Action"
}

variable "org_name" {
  type        = string
  description = "Name of the org for the Github Action"
}

variable "gh_token" {
  type        = string
  description = "Github token that is used for generating Self Hosted Runner Token"
}

variable "instance_name" {
  type        = string
  description = "The gce instance name"
  default     = "gh-runner"
}

variable "target_size" {
  type        = number
  description = "The number of runner instances"
  default     = 1
}

variable "service_account" {
  description = "Service account email address"
  type        = string
  default     = ""
}
variable "additional_metadata" {
  type        = map(any)
  description = "Additional metadata to attach to the instance"
  default     = {}
}
variable "machine_type" {
  type        = string
  description = "The GCP machine type to deploy"
  default     = "n1-standard-1"
}

variable "source_image_family" {
  type        = string
  description = "Source image family. If neither source_image nor source_image_family is specified, defaults to the latest public Ubuntu image."
  default     = "ubuntu-minimal-1804-lts"
}

variable "source_image_project" {
  type        = string
  description = "Project where the source image comes from"
  default     = "ubuntu-os-cloud"
}

variable "source_image" {
  type        = string
  description = "Source disk image. If neither source_image nor source_image_family is specified, defaults to the latest public CentOS image."
  default     = ""
}

variable "startup_script" {
  type        = string
  description = "User startup script to run when instances spin up"
  default     = ""
}

variable "shutdown_script" {
  type        = string
  description = "User shutdown script to run when instances shutdown"
  default     = ""
}

variable "custom_metadata" {
  type        = map(any)
  description = "User provided custom metadata"
  default     = {}
}

variable "cooldown_period" {
  description = "The number of seconds that the autoscaler should wait before it starts collecting information from a new instance."
  default     = 60
}
