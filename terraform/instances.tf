############## SERVICE ##############

resource "yandex_compute_instance" "healthchecker" {
  count = 2
  name = "hw2-service-${count.index + 1}"
  hostname = "hw2-service-${count.index + 1}"
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

############## NAT ##############

resource "yandex_vpc_subnet" "nat-public-subnet" {
  network_id     = yandex_vpc_network.hw2-network.id
  v4_cidr_blocks = ["10.100.0.0/24"]
  zone           = var.zone
  depends_on     = [yandex_vpc_network.hw2-network]
}

resource "yandex_vpc_subnet" "nat-subnet" {
  network_id     = yandex_vpc_network.hw2-network.id
  v4_cidr_blocks = ["172.16.0.0/24"]
  zone           = var.zone
  route_table_id = yandex_vpc_route_table.nat-table.id
  depends_on     = [yandex_vpc_network.hw2-network, yandex_vpc_route_table.nat-table]
}

resource "yandex_vpc_route_table" "nat-table" {
  network_id = yandex_vpc_network.hw2-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat.network_interface.0.ip_address
  }

  depends_on = [yandex_compute_instance.nat]
}

data "yandex_compute_image" "nat-instance" {
  family = "nat-instance-ubuntu"
}

resource "yandex_compute_instance" "nat" {
  name        = "hw2-nat"
  hostname    = "hw2-nat"
  platform_id = "standard-v2"
  folder_id   = var.folder_id

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.nat-instance.id
      size     = 13
      type     = "network-hdd"
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.nat-public-subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "artem:${file("~/.ssh/id_rsa.pub")}"
  }

  depends_on = [yandex_vpc_subnet.nat-public-subnet]
}
