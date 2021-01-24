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
  folder_id = var.folder_id
}

resource "yandex_iam_service_account_iam_binding" "hw2-b" {
  service_account_id = yandex_iam_service_account.hw2-sa.id
  role = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.hw2-sa.id}",
  ]
}

############## IMAGE ##############

data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

############## SERVICE ##############

resource "yandex_compute_instance" "healthchecker" {
  name = "hw2-health-checker"
  hostname = "hw2-health-checker"
  platform_id = "standard-v2"
  folder_id = var.folder_id

  resources {
    cores = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      size = 13
      type = "network-hdd"
    }
  }

  scheduling_policy {
    preemptible = true
  }

  service_account_id = yandex_iam_service_account.hw2-sa.id

  network_interface {
    subnet_id = yandex_vpc_subnet.hw2-subnet.id
    nat = false
  }

  metadata = {
    docker-container-declaration = file("${path .module}/service.yaml")
    ssh-keys = "artem:${file("~/.ssh/id_rsa.pub")}"
  }
}

############## POSTGRES ##############

resource "yandex_compute_instance" "postgres" {
  name = "hw2-postgres"
  hostname = "hw2-postgres"
  platform_id = "standard-v2"
  folder_id = var.folder_id

  resources {
    cores = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      size = 13
      type = "network-hdd"
    }
  }

  scheduling_policy {
    preemptible = true
  }

  service_account_id = yandex_iam_service_account.hw2-sa.id

  network_interface {
    subnet_id = yandex_vpc_subnet.hw2-subnet.id
    nat = false
  }

  metadata = {
    docker-container-declaration = file("${path.module}/postgres.yaml")
    ssh-keys = "artem:${file("~/.ssh/id_rsa.pub")}"
  }
}

############## NGINX ##############

resource "yandex_compute_instance" "nginx" {
  name = "hw2-nginx"
  hostname = "hw2-nginx"
  platform_id = "standard-v2"
  folder_id = var.folder_id

  resources {
    cores = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      size = 13
      type = "network-hdd"
    }
  }

  scheduling_policy {
    preemptible = true
  }

  service_account_id = yandex_iam_service_account.hw2-sa.id

  network_interface {
    subnet_id = yandex_vpc_subnet.hw2-subnet.id
    nat = true
  }

  metadata = {
    docker-container-declaration = file("${path.module}/nginx.yaml")
    ssh-keys = "artem:${file("~/.ssh/id_rsa.pub")}"
  }
}
