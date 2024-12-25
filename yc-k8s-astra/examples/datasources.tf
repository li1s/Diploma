data "yandex_vpc_network" "interconnect" {
  name      = "interconnect-net"
  folder_id = var.folder_id_interconnect
}

data "yandex_vpc_subnet" "subnet-interconnect-a" {
  name      = "subnet-interconnect-a2"
  folder_id = var.folder_id_interconnect
}
