# 1. Definición del volumen base (Cambiamos la ruta a la de tu usuario)
resource "libvirt_volume" "os_image_base" {
  name   = "${var.hostname}-base.qcow2"
  pool   = "default"
  source = "/home/alexhozt/kvm/discos/rocky9.qcow2"
  format = "qcow2"
}

# 2. Volumen de la VM (basado en el anterior)
resource "libvirt_volume" "os_image" {
  name           = "${var.hostname}-os_image.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.os_image_base.id
  size           = var.diskSize * 1024 * 1024 * 1024
}

# 3. Configuración de Cloud-init (Usando tu nueva llave SSH)
data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/config/cloud_init.cfg", {
      hostname   = var.hostname
      fqdn       = "${var.hostname}.${var.domain}"
      public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
    })
  }
}

# 4. Disco de Cloud-init
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "${var.hostname}-commoninit.iso"
  pool           = "default"
  user_data      = data.cloudinit_config.config.rendered
  network_config = file("${path.module}/config/network_config_${var.ip_type}.cfg")
}

# 5. Dominio / Máquina Virtual
resource "libvirt_domain" "domain-server" {
  name   = var.hostname
  memory = var.memoryMB
  vcpu   = var.cpu

  machine  = "q35"
  firmware = "/usr/share/OVMF/OVMF_CODE_4M.fd"

  nvram {
    file     = "/var/lib/libvirt/qemu/nvram/${var.hostname}_VARS.fd"
    template = "/usr/share/OVMF/OVMF_VARS_4M.fd"
  }

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.os_image.id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default"
  }

  xml {
    xslt = file("${path.module}/cdrom_sata.xsl")
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
