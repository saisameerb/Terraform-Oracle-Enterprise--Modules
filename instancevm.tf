#pin the provider version
provider "vsphere" { version = "1.3.0" }

module "data" {
  source        = "data"
  default 	= "${var.default}"
  vms		= "${var.vms}"
  disks		= "${var.disks}"
}

resource "vsphere_virtual_machine" "oracle" {
  # Number of VMs to create.  
  count           = "${length(var.vms)}"

  # pulls name from a map
  name            = "${lookup(var.vms[count.index], "name", join("", list(lookup(var.vms[count.index], "prefix", var.default["prefix"]), format("%d", count.index + lookup(var.default, "name_start_count", 1)), lookup(var.vms[count.index], "suffix", var.default["suffix"]))))}"

  # number of VCPUs
  num_cpus              = "${lookup(var.vms[count.index], "cpu", var.default["cpu"])}"

  # set the scsi controller count as the disks are to be assigned to different controllers
  scsi_controller_count = 4

  # Ram to assign in MB
  memory          = "${lookup(var.vms[count.index], "memory", var.default["memory"])}"
  guest_id        = "${module.data.template_guest_id}"

  # VM Location configuration, must exist
  folder           = "${lookup(var.vms[count.index], "project",  var.default["project"])}"
  resource_pool_id = "${module.data.resource_pool}"
  datastore_id     = "${module.data.datastore_id}"

  # Network configuration
  network_interface {
    network_id = "${module.data.network_id1}"
  }

  network_interface {
    network_id = "${module.data.network_id2}"
  }

  network_interface {
    network_id = "${module.data.network_id3}"
  }

  # this exposes the uuids of attached disks to VM and thus allowing them to be accessed from guest
  enable_disk_uuid = "true"

  # VM Disk Configuration
  disk {
    datastore_id        = "${module.data.datastore_id}"
    size                = "${module.data.template_size}" 
    label               = "${lookup(var.vms[count.index], "label", join("", list(lookup(var.vms[count.index], "prefix", var.default["prefix"]), format("%d", count.index + lookup(var.default, "name_start_count", 1)), lookup(var.vms[count.index], "suffix", var.default["suffix"]))))}_disk0.vmdk"
    unit_number         = 0 
  }
  disk {
    datastore_id        = "${module.data.datastore_id}"
    size                = "${lookup(var.vms[count.index], "size", var.default["add_disk1_size"])}"
    label               = "${lookup(var.vms[count.index], "label", join("", list(lookup(var.vms[count.index], "prefix", var.default["prefix"]), format("%d", count.index + lookup(var.default, "name_start_count", 1)), lookup(var.vms[count.index], "suffix", var.default["suffix"]))))}_${lookup(var.vms[count.index], "add_disk_suffix", var.default["add_disk_suffix1"])}.vmdk"
    unit_number         = 1
  }
  disk {
    datastore_id        = "${module.data.datastore_id}"
    size                = "${lookup(var.vms[count.index], "size", var.default["add_disk2_size"])}"
    label               = "${lookup(var.vms[count.index], "label", join("", list(lookup(var.vms[count.index], "prefix", var.default["prefix"]), format("%d", count.index + lookup(var.default, "name_start_count", 1)), lookup(var.vms[count.index], "suffix", var.default["suffix"]))))}_${lookup(var.vms[count.index], "add_disk_suffix1", var.default["add_disk_suffix2"])}.vmdk"
    unit_number         = 2
  }

 # Attach shared disks. disk_sharing is commented out as it is supported from vsphere version 6.0. Can be uncommented when version criteria is met.
  disk {
    datastore_id        = "${module.data.voting}"
    label               = "${var.default["prefix"]}_${lookup(var.votingDisks[0], "name")}_shared_disk.vmdk"
    # disk_sharing        = "sharingMultiWriter"
    unit_number         = 15
    attach              = "true"
    path                = "${var.default["prefix"]}_${lookup(var.votingDisks[0], "name")}_shared_disk.vmdk"
    thin_provisioned    = "false"
    disk_mode           = "independent_persistent"
  }
  disk {
    datastore_id        = "${module.data.voting}"
    label               = "${var.default["prefix"]}_${lookup(var.votingDisks[1], "name")}_shared_disk.vmdk"
    # disk_sharing        = "sharingMultiWriter"
    unit_number         = 16
    attach              = "true"
    path                = "${var.default["prefix"]}_${lookup(var.votingDisks[1], "name")}_shared_disk.vmdk"
    thin_provisioned    = false
    disk_mode           = "independent_persistent"
  }
  disk {
    datastore_id        = "${module.data.voting}"
    label               = "${var.default["prefix"]}_${lookup(var.votingDisks[2], "name")}_shared_disk.vmdk"
    # disk_sharing        = "sharingMultiWriter"
    unit_number         = 17
    attach              = "true"
    path                = "${var.default["prefix"]}_${lookup(var.votingDisks[2], "name")}_shared_disk.vmdk"
    thin_provisioned	= false
    disk_mode		= "independent_persistent"
  }
  disk {
    datastore_id        = "${module.data.redo}"
    label               = "${var.default["prefix"]}_${lookup(var.redoDisks[0], "name")}_shared_disk.vmdk"
    # disk_sharing        = "sharingMultiWriter"
    unit_number         = 18
    attach              = "true"
    path                = "${var.default["prefix"]}_${lookup(var.redoDisks[0], "name")}_shared_disk.vmdk"
    thin_provisioned    = false
    disk_mode           = "independent_persistent"
  }
  disk {
    datastore_id        = "${module.data.redo}"
    label               = "${var.default["prefix"]}_${lookup(var.redoDisks[1], "name")}_shared_disk.vmdk"
    # disk_sharing        = "sharingMultiWriter"
    unit_number         = 19
    attach              = "true"
    path                = "${var.default["prefix"]}_${lookup(var.redoDisks[1], "name")}_shared_disk.vmdk"
    thin_provisioned    = false
    disk_mode           = "independent_persistent"
  }
  disk {
    datastore_id        = "${module.data.db1}"
    label               = "${var.default["prefix"]}_${lookup(var.db1Disks[0], "name")}_shared_disk.vmdk"
    # disk_sharing        = "sharingMultiWriter"
    unit_number         = 30
    attach              = "true"
    path                = "${var.default["prefix"]}_${lookup(var.db1Disks[0], "name")}_shared_disk.vmdk"
    thin_provisioned    = false
    disk_mode           = "independent_persistent"
  }
  disk {
    datastore_id        = "${module.data.db1}"
    label               = "${var.default["prefix"]}_${lookup(var.db1Disks[1], "name")}_shared_disk.vmdk"
    # disk_sharing        = "sharingMultiWriter"
    unit_number         = 31
    attach              = "true"
    path                = "${var.default["prefix"]}_${lookup(var.db1Disks[1], "name")}_shared_disk.vmdk"
    thin_provisioned    = false
    disk_mode           = "independent_persistent"
  }
  disk {
    datastore_id        = "${module.data.db2}"
    label               = "${var.default["prefix"]}_${lookup(var.db2Disks[0], "name")}_shared_disk.vmdk"
    # disk_sharing        = "sharingMultiWriter"
    unit_number         = 45
    attach              = "true"
    path                = "${var.default["prefix"]}_${lookup(var.db2Disks[0], "name")}_shared_disk.vmdk"
    thin_provisioned    = false
    disk_mode           = "independent_persistent"
  }
  disk {
    datastore_id        = "${module.data.db2}"
    label               = "${var.default["prefix"]}_${lookup(var.db2Disks[1], "name")}_shared_disk.vmdk"
    # disk_sharing        = "sharingMultiWriter"
    unit_number         = 46
    attach              = "true"
    path                = "${var.default["prefix"]}_${lookup(var.db2Disks[1], "name")}_shared_disk.vmdk"
    thin_provisioned    = false
    disk_mode           = "independent_persistent"
  }
  disk {
    datastore_id        = "${module.data.export}"
    label               = "${var.default["prefix"]}_${lookup(var.exportDisks[0], "name")}_shared_disk.vmdk"
    # disk_sharing        = "sharingMultiWriter"
    unit_number         = 3
    attach              = "true"
    path                = "${var.default["prefix"]}_${lookup(var.exportDisks[0], "name")}_shared_disk.vmdk"
    thin_provisioned    = false
    disk_mode           = "independent_persistent"
  }
  disk {
    datastore_id        = "${module.data.export}"
    label               = "${var.default["prefix"]}_${lookup(var.exportDisks[1], "name")}_shared_disk.vmdk"
    # disk_sharing        = "sharingMultiWriter"
    unit_number         = 4
    attach              = "true"
    path                = "${var.default["prefix"]}_${lookup(var.exportDisks[1], "name")}_shared_disk.vmdk"
    thin_provisioned    = false
    disk_mode           = "independent_persistent"
  }
  disk {
    datastore_id        = "${module.data.export}"
    label               = "${var.default["prefix"]}_${lookup(var.exportDisks[2], "name")}_shared_disk.vmdk"
    # disk_sharing        = "sharingMultiWriter"
    unit_number         = 5
    attach              = "true"
    path                = "${var.default["prefix"]}_${lookup(var.exportDisks[2], "name")}_shared_disk.vmdk"
    thin_provisioned    = false
    disk_mode           = "independent_persistent"
  }


  clone {

    template_uuid       = "${module.data.template_id}"

    customize {

      linux_options {
        host_name = "${lookup(var.vms[count.index], "host_name", join("", list(lookup(var.vms[count.index], "prefix", var.default["prefix"]), format("%d", count.index + lookup(var.default, "name_start_count", 1)), lookup(var.vms[count.index], "suffix", var.default["suffix"]))))}"
        domain    = "${lookup(var.vms[count.index], "domain",  var.default["domain"])}"
      }

      dns_suffix_list     = "${split(";;", lookup(var.vms[count.index], "dns_suffix_list",  var.default["dns_suffix_list"]))}"
      dns_server_list     = "${split(";;", lookup(var.vms[count.index], "dns_server_list",  var.default["dns_server_list"]))}"

      network_interface {
        ipv4_address = "${lookup(var.vms[count.index], "ip")}"
        ipv4_netmask = "${lookup(var.vms[count.index], "net_prefix",  var.default["net1_prefix"])}"
      }
      network_interface {
        ipv4_address = "${lookup(var.vms[count.index], "ip2")}"
        ipv4_netmask = "${lookup(var.vms[count.index], "net_prefix",  var.default["net2_prefix"])}"
      }
      network_interface {
        ipv4_address = "${lookup(var.vms[count.index], "ip3")}"
        ipv4_netmask = "${lookup(var.vms[count.index], "net_prefix",  var.default["net3_prefix"])}"
      }

      ipv4_gateway        = "${lookup(var.vms[count.index], "gateway",  var.default["gateway1"])}"
    }
  }

  # Chef configuration
  provisioner "chef" {
    environment         = "${lookup(var.vms[count.index], "chef-environment",  var.default["chef-environment"])}"
    run_list            = "${split(";;", lookup(var.vms[count.index], "chef-run_list",  var.default["chef-run_list"]))}"
    server_url          = "${lookup(var.vms[count.index], "chef-server_url",  var.default["chef-server_url"])}"
    attributes_json     = "${lookup(var.vms[count.index], "chef-attributes_json",  var.default["chef-attributes_json"])}"
    recreate_client     = true
    skip_install        = "${lookup(var.vms[count.index], "chef-skip_client_install", lookup(var.default, "chef-skip_client_install", false))}"

   # Node name should be FQDN in Chef
    node_name           = "${lookup(var.vms[count.index], "name", join("", list(lookup(var.vms[count.index], "prefix", var.default["prefix"]), format("%d", count.index + lookup(var.default, "name_start_count", 1)), lookup(var.vms[count.index], "suffix", var.default["suffix"]))))}.${lookup(var.vms[count.index], "domain",  var.default["domain"])}"

   # username of user with bootstrap permissions
    user_name           = "${lookup(var.vms[count.index], "chef-user_name",  var.default["chef-user_name"])}"

   # Assumes your chef private key is in ~/.chef/ directory
    user_key            = "${file("~/.chef/${lookup(var.vms[count.index], "chef-user_name",  var.default["chef-user_name"])}.pem")}"

   # Disable SSL verification since we're using self signed certs on the Chef server.
    ssl_verify_mode     = "${lookup(var.vms[count.index], "chef-ssl_verify_mode",  var.default["chef-ssl_verify_mode"])}"

   # Chef client version
    version             = "${lookup(var.vms[count.index], "chef-client_version",  var.default["chef-client_version"])}"

   # Connection to VM information
    connection {
      user              = "${lookup(var.vms[count.index], "vm-initial_user",  var.default["vm-initial_user"])}"
      password          = "${lookup(var.vms[count.index], "vm-initial_password",  var.default["vm-initial_password"])}"
    }
  }

# NOPASSWD sudoers cleanup
  provisioner "remote-exec" {
   # Powering off the VM as vsphere does not have the disk sharing capability on vsphere versions less than 6.0 and creates disk locks which fails the provisioning of other resources.
   # You may choose to create this file on your template to grant temporary sudo access to a provisioning user
    inline = [
      "sudo shutdown -P && sudo rm -f /etc/sudoers.d/silver"
    ]

   # Connection to VM information, as above
    connection {
      user              = "${lookup(var.vms[count.index], "vm-initial_user",  var.default["vm-initial_user"])}"
      password          = "${lookup(var.vms[count.index], "vm-initial_password",  var.default["vm-initial_password"])}"
     # Evade the noexec on /tmp, as tf will cache a script to execute
      script_path = "/home/silver/provision.sh"
    }
  }
}
