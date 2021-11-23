#!/bin/bash
# Based on https://git.geco-it.net/GECO-IT-PUBLIC/fedora-coreos-proxmox

VMID="9000"
VMSTORAGE="local-lvm"
VMDISK_OPTIONS=",discard=on"
IMAGES_DIR=/var/lib/vz/images

STREAMS=stable
VERSION=35.20211029.3.0
BASEURL=https://builds.coreos.fedoraproject.org

# Download Fedora CoreOS
[[ ! -e ${IMAGES_DIR}/fedora-coreos-${VERSION}-qemu.x86_64.qcow2 ]]&& {
    # Cleanup old versions
    rm ${IMAGES_DIR}/fedora-coreos-* 2> /dev/null
    echo "Download Fedora CoreOS..."
    wget -q -P ${IMAGES_DIR} --show-progress ${BASEURL}/prod/streams/${STREAMS}/builds/${VERSION}/x86_64/fedora-coreos-${VERSION}-qemu.x86_64.qcow2.xz
    xz -dv ${IMAGES_DIR}/fedora-coreos-${VERSION}-qemu.x86_64.qcow2.xz
}

# Storage Type
echo -n "Get storage \"${VMSTORAGE}\" type... "
case "$(pvesh get /storage/${VMSTORAGE} --noborder --noheader | grep ^type | awk '{print $2}')" in
        dir|nfs|cifs|glusterfs|cephfs) VMSTORAGE_type="file"; echo "[file]"; ;;
        lvm|lvmthin|iscsi|iscsidirect|rbd|zfs|zfspool) VMSTORAGE_type="block"; echo "[block]" ;;
        *)
                echo "[unknown]"
                exit 1
        ;;
esac

# Import Fedora Disk
if [[ "x${VMSTORAGE_type}" = "xfile" ]]
then
	vmdisk_name="${VMID}/vm-${VMID}-disk-0.qcow2"
	vmdisk_format="--format qcow2"
else
	vmdisk_name="vm-${VMID}-disk-0"
  vmdisk_format=""
fi

# Destroy current template
echo "Destroy current VM ${VMID}..."
qm destroy ${VMID} --destroy-unreferenced-disks 1 --purge 1 2> /dev/null

# Create VM
echo "Create Fedora CoreOS VM ${VMID}"
qm create ${VMID} --name "coreos-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk ${VMID} ${IMAGES_DIR}/fedora-coreos-${VERSION}-qemu.x86_64.qcow2 ${VMSTORAGE} ${vmdisk_format}
qm set ${VMID} --scsihw virtio-scsi-pci --scsi0 ${VMSTORAGE}:${vmdisk_name}${VMDISK_OPTIONS}
qm set ${VMID} --boot c --bootdisk scsi0
qm set ${VMID} --serial0 socket --vga serial0
qm set ${VMID} --description "Fedora CoreOS ${VERSION} Template"

# Convert VM Template
echo -n "Convert VM ${VMID} in Proxmox VM template... "
qm template ${VMID} &> /dev/null || true
echo "[done]"
