############## VARIABLES ##############

variable "token" {}
variable "folder_id" {}
variable "cloud_id" {}
variable "zone" {
  default = "ru-central1-a"
}

############## PROVIDER ##############

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.49.0"
    }
  }
}

provider "yandex" {
  token = var.token
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  zone = var.zone
}

############## NETWORK ##############

resource "yandex_vpc_network" "hw2-network" {
  name = "hw2-network"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "hw2-subnet" {
  network_id = yandex_vpc_network.hw2-network.id
  v4_cidr_blocks = [
    "192.168.0.0/16"]
  zone = var.zone
}

############## ACCOUNT ##############

resource "yandex_iam_service_account" "hw2-sa" {
  name = "hw2"
}

resource "yandex_resourcemanager_folder_iam_binding" "hw2-b" {
  folder_id = var.folder_id
  role = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.hw2-sa.id}",
  ]
}

############## IMAGE ##############

data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}
