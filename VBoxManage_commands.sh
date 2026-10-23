# Comandos usados para crear la VM Lab5-Alpine.
# El disco queda fuera del repositorio, en la carpeta de VirtualBox.

VBoxManage createvm --name "Lab5-Alpine" --ostype "Linux_64" --register
VBoxManage modifyvm "Lab5-Alpine" --memory 1024 --vram 16 --cpus 1 --nic1 nat
VBoxManage createmedium disk --filename "C:\Users\juand\VirtualBox VMs\Lab5-Alpine\Lab5-Alpine.vdi" --size 10240 --format VDI
VBoxManage storagectl "Lab5-Alpine" --name "SATA" --add sata
VBoxManage storageattach "Lab5-Alpine" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "C:\Users\juand\VirtualBox VMs\Lab5-Alpine\Lab5-Alpine.vdi"
VBoxManage storagectl "Lab5-Alpine" --name "IDE" --add ide
VBoxManage storageattach "Lab5-Alpine" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "C:\Users\juand\Downloads\alpine-standard-3.19.0-x86_64.iso"

# Despues de instalar Alpine y apagar la VM, se quita el CD para arrancar desde el disco.
VBoxManage storageattach "Lab5-Alpine" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium none

# Red solo con el PC anfitrion. El servidor DHCP de esa red ya existia.
VBoxManage controlvm "Lab5-Alpine" poweroff
VBoxManage modifyvm "Lab5-Alpine" --nic1 hostonly --hostonlyadapter1 "VirtualBox Host-Only Ethernet Adapter"

# Red puente: la VM queda en el mismo Wi-Fi que el PC.
VBoxManage controlvm "Lab5-Alpine" poweroff
VBoxManage modifyvm "Lab5-Alpine" --nic1 bridged --bridgeadapter1 "Intel(R) Wireless-AC 9560"

# Volver a NAT para poder instalar programas, y guardar la foto limpia.
VBoxManage controlvm "Lab5-Alpine" poweroff
VBoxManage modifyvm "Lab5-Alpine" --nic1 nat
VBoxManage snapshot "Lab5-Alpine" take "snap_base" --description "Alpine Linux 3.19 recien instalado, sin modificaciones"
VBoxManage snapshot "Lab5-Alpine" take "snap_con_herramientas" --description "Alpine con curl, wget, nano y htop instalados"
VBoxManage snapshot "Lab5-Alpine" list
VBoxManage controlvm "Lab5-Alpine" poweroff
VBoxManage snapshot "Lab5-Alpine" restore "snap_base"
VBoxManage startvm "Lab5-Alpine" --type gui

# 2 CPUs, 2048 MB y disco fijo de 4 GB en el segundo puerto SATA.
VBoxManage controlvm "Lab5-Alpine" poweroff
VBoxManage modifyvm "Lab5-Alpine" --cpus 2 --memory 2048
VBoxManage createmedium disk --filename "C:\Users\juand\VirtualBox VMs\Lab5-Alpine\Lab5-Alpine-fixed.vdi" --size 4096 --format VDI --variant Fixed
VBoxManage storageattach "Lab5-Alpine" --storagectl "SATA" --port 1 --device 0 --type hdd --medium "C:\Users\juand\VirtualBox VMs\Lab5-Alpine\Lab5-Alpine-fixed.vdi"
VBoxManage startvm "Lab5-Alpine" --type gui

# El disco fijo no entra en el OVA. Se desconecta y se exporta solo el disco del sistema.
VBoxManage controlvm "Lab5-Alpine" poweroff
VBoxManage storageattach "Lab5-Alpine" --storagectl "SATA" --port 1 --device 0 --type hdd --medium none
VBoxManage export "Lab5-Alpine" --output "C:\Users\juand\VirtualBox VMs\Lab5-Alpine\Lab5-Alpine-export.ova" --manifest --options manifest
