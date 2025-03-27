resource "yandex_mdb_postgresql_cluster" "mypg" {
  name                = "mypg"
  environment         = "PRODUCTION"
  network_id          = yandex_vpc_network.mynet.id
  security_group_ids  = [ yandex_vpc_security_group.pgsql-sg.id ]
  deletion_protection = false

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-hdd"
      disk_size          = "10"
    }

  }

  host {
   zone                    = "ru-central1-a"
    subnet_id               = yandex_vpc_subnet.mysubnet-a.id
    assign_public_ip        = true
  }

  host {
    zone                    = "ru-central1-b"
    subnet_id               = yandex_vpc_subnet.mysubnet-b.id
    assign_public_ip        = true
  }

}

resource "yandex_mdb_postgresql_database" "db1" {
  cluster_id = yandex_mdb_postgresql_cluster.mypg.id
  name       = "db1"
  owner      = "travitskii"
}

resource "yandex_mdb_postgresql_user" "travitskii" {
  cluster_id = yandex_mdb_postgresql_cluster.mypg.id
  name       = "travitskii"
  password   = "24101967cO"
}

resource "yandex_vpc_network" "mynet" {
  name = "mynet"
}

resource "yandex_vpc_subnet" "mysubnet-a" {
  name           = "mysubnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.mynet.id
  v4_cidr_blocks = ["10.5.0.0/16"]
}

resource "yandex_vpc_subnet" "mysubnet-b" {
  name           = "mysubnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.mynet.id
  v4_cidr_blocks = ["10.6.0.0/16"]
}


resource "yandex_vpc_security_group" "pgsql-sg" {
  name       = "pgsql-sg"
  network_id = yandex_vpc_network.mynet.id

  ingress {
    description    = "PostgreSQL"
    port           = 6432
    protocol       = "TCP"
    v4_cidr_blocks = [ "0.0.0.0/0" ]
  }
}


