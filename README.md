# Rocky Linux 9 Infrastructure as Code (IaC)

Este proyecto automatiza el despliegue de una infraestructura virtualizada utilizando **Terraform** y el proveedor de **Libvirt**. Está diseñado para ejecutarse en entornos Linux (KVM/QEMU) y utiliza **Cloud-init** para la personalización dinámica de instancias de Rocky Linux 9.

---

## Guía de Operación y Configuración

### 1. Requisitos de Software en el Host
Para que Terraform pueda interactuar con el hipervisor y procesar las configuraciones, instala las siguientes dependencias en tu Ubuntu:

```bash
# Virtualización y gestión de red
sudo apt update && sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

# Procesamiento de configuración (Requerido por Terraform)
# xsltproc: Procesa el archivo cdrom_sata.xsl
# genisoimage: Crea la ISO de Cloud-init
sudo apt install -y xsltproc genisoimage
```

### 2. Preparación de Archivos y Rutas
El proyecto está configurado para el usuario `alexhozt`. Asegúrate de cumplir con estas rutas:

* **Imagen OS:** Descarga la imagen `GenericCloud` de Rocky Linux 9 y colócala en:
    `~/ruta/rocky9.qcow2`
* **Permisos de Carpeta:** Libvirt necesita permisos para leer tu Home. Ejecuta:
    `chmod 755 /home/usuario`
* **Llaves SSH:** Genera tu par de llaves si no existen:
    `ssh-keygen -t ed25519` (Terraform leerá `~/.ssh/id_ed25519.pub`).

---

## Estructura del Código

- **`main.tf`**: Orquestador principal. Define el volumen base, el disco de la VM (copy-on-write) y los parámetros del dominio.
- **`variables.tf`**: Centraliza la configuración de hardware (CPU, RAM, Disco).
- **`provider.tf`**: Establece la conexión con el socket de Libvirt (`qemu:///system`).
- **`config/cloud_init.cfg`**: Define el usuario `alexhozt`, inyecta la llave SSH y otorga permisos `sudo`.
- **`cdrom_sata.xsl`**: Un parche XML necesario para que el CD-ROM de Cloud-init funcione correctamente bajo arquitecturas modernas (Q35/SATA).

---

##  Despliegue Paso a Paso

1.  **Inicialización:**
    Descarga los plugins necesarios (Libvirt y Cloud-init).
    ```bash
    terraform init
    ```

2.  **Validación y Planificación:**
    Genera un plan para verificar rutas y recursos.
    ```bash
    terraform plan -out=lab.tfplan
    ```

3.  **Ejecución:**
    Aplica la configuración para levantar la VM.
    ```bash
    terraform apply lab.tfplan
    ```

---

## Acceso y Mantenimiento

Una vez desplegada, la máquina no permite acceso por contraseña por seguridad. Debes usar tu llave privada SSH:

```bash
# 1. Localiza la IP asignada
virsh net-dhcp-leases default

# 2. Conecta vía SSH
ssh usuario@<IP_DETECTADA>
```

### Comandos de Utilidad
- **Ver estado:** `virsh list --all`
- **Consola serial:** `virsh console <hostname>`
- **Eliminar todo:** `terraform destroy -auto-approve`

---
**Desarrollado por:** alexhozt  
**Entorno:** Ubuntu 24.04 / Libvirt / Terraform v1.x
```
