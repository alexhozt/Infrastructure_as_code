
variable "hostname" {
  default = "rocky9"
  description = "Servidor de prueba OpenSuse"
}

variable "domain" {
  default = "midominio.org"
}

variable "ip_type" {
  default = "dhcp"
}

variable "memoryMB" {
  default = 1024*2
}

variable "cpu" {
  default = 1
}

variable "diskSize" {
  default = 24
}

variable "path_to_image" {
  default = "/home/alexhozt/kvm/discos"
}

