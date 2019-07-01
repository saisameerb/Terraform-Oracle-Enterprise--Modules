#pin the provider version
provider "vsphere" { version = "1.3.0" }

resource "vsphere_virtual_disk" "voting_disks" {
    count            = "${length(var.voting_disks)}"
    size             = "${var.default["disk_size_vo"]}"
    vmdk_path        = "${var.default["prefix"]}_${lookup(var.voting_disks[count.index], "name")}_shared_disk.vmdk"
    datacenter       = "${var.default["datacenter"]}"
    datastore        = "${var.default["datastore-vo"]}"
    type             = "eagerZeroedThick" #need to be changed to lazy when vsphere is upgraded to 6.0
}

resource "vsphere_virtual_disk" "redo_disks" {
    count            = "${length(var.redo_disks)}"
    size             = "${var.default["disk_size_re"]}"
    vmdk_path        = "${var.default["prefix"]}_${lookup(var.redo_disks[count.index], "name")}_shared_disk.vmdk"
    datacenter       = "${var.default["datacenter"]}"
    datastore        = "${var.default["datastore-re"]}"
    type             = "eagerZeroedThick" #need to be changed to lazy when vsphere is upgraded to 6.0
}

resource "vsphere_virtual_disk" "db1_disks" {
    count            = "${length(var.db1_disks)}"
    size             = "${var.default["disk_size_vo"]}"
    vmdk_path        = "${var.default["prefix"]}_${lookup(var.db1_disks[count.index], "name")}_shared_disk.vmdk"
    datacenter       = "${var.default["datacenter"]}"
    datastore        = "${var.default["datastore-d1"]}"
    type             = "eagerZeroedThick" #need to be changed to lazy when vsphere is upgraded to 6.0
}

resource "vsphere_virtual_disk" "db2_disks" {
    count            = "${length(var.db2_disks)}"
    size             = "${var.default["disk_size_vo"]}"
    vmdk_path        = "${var.default["prefix"]}_${lookup(var.db2_disks[count.index], "name")}_shared_disk.vmdk"
    datacenter       = "${var.default["datacenter"]}"
    datastore        = "${var.default["datastore-d2"]}" #need to be changed to lazy when vsphere is upgraded to 6.0
    type             = "eagerZeroedThick"
}

resource "vsphere_virtual_disk" "export_disks" {
    count            = "${length(var.export_disks)}"
    size             = "${var.default["disk_size_ex"]}"
    vmdk_path        = "${var.default["prefix"]}_${lookup(var.export_disks[count.index], "name")}_shared_disk.vmdk"
    datacenter       = "${var.default["datacenter"]}"
    datastore        = "${var.default["datastore-ex"]}"
    type             = "eagerZeroedThick" #need to be changed to lazy when vsphere is upgraded to 6.0
}
