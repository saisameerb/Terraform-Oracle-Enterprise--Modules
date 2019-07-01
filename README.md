
# Objective
The modules herein are for the purpose of creating the disks and vms for an Oracle enterprise.

# Usage

## Prerequisites
Before using these modules, make sure that:
- For Disk module - Verify the thick provisioning capability on all the datastores used in variables

## Workflow

Generally the workflow is as follows:

* Initialize terraform (create workspace, run `terraform init` to download modules, etc.)
* Create environment specific `.tfvars` file (this contains all the "runtime" settings such as IPs, etc.)
* Provision the shared disks
* Provision the VMs serially

## Set Up

Refer to the `https://chalk.charter.com/display/VIDEOPS/Creating+Terraform+Repos` for creating a Terraform Repo.  

### Initialize

Create a new workspace.

    terraform workspace new ctec-test

If using Consul for remote state, create a `backend.<environment>.consul` e.g.: `backend.ctec-test.consul`

Initialize terraform to download plugins. (if not using remote state omit the `-backend-config`)

    terraform init -backend-config=backend.ctec-test.consul

## Create Variables

Copy the skeleton tfvars file from `skel/tfvars` to `your-environment.tfvars`

Update any settings for your environment.


### Variables

| Variable                 	| Definition                              								|
|-------------------------------|-------------------------------------------------------------------------------------------------------|
| `vsphere_server`           	| Address of vSphere server to connect.   								|
| `vsphere_user`             	| User with whom to connect to authenticate with vSphere. 						|
| `vsphere_password`         	| Password with which to authenticate with vsphere vSphere 						|
| `datacenter`               	| Name of the Datacenter as it appears in vSphere 							|
| `datastore`                	| Path to Datastore where VM will be deployed. 								|
| `datastore-vo`                | Path to Datastore where the voting disks will be deployed. 						|
| `datastore-re`                | Path to Datastore where the redo disks will be deployed. 						|
| `datastore-d1`                | Path to Datastore where the data1 disks will be deployed. 						|
| `datastore-d2`                | Path to Datastore where the data2 disks will be deployed. 						|
| `datastore-ex`                | Path to Datastore where the export disks will be deployed. 						|
| `cluster`                  	| Name of the Host Cluster as it appears in vSphere 							|
| `net_label1`                  | Name of the Network to attach the Primary interface. 							|
| `net_label2`                  | Name of the Network to attach the first additional interface. 					|
| `net_label3`                  | Name of the Network to attach the second additional interface. 					|
| `template`            	| Path to OS image template, include names of any folders. 						|
| `prefix`                  	| Prefix/Name for the VM (eg: vms, ams etc) 								|
| `suffix`			| six digit KMA that the server belongs to (eg: bodcma, pvdcco) 					|
| `vm_username`              	| Username to connect to VM										|
| `vm_password`              	| Password for initial connection. 									|
| `vm_domain`               	| Domain of Vcenter and the vms to be built. 								|
| `vm_num_cpus`              	| Number of CPUs to assign to the New VM 								|
| `vm_memory`                	| Memory in MB to assign to the New VM 									|
| `vm-initial-username`         | Username to connect to the VM/s. 									|
| `vm-initial-password`         | Password to connect to the VM/s. 									|
| `dns_server_list`       	| List of DNS Servers.  Separated with ";;" 								|
| `dns_suffix_list`       	| List of DNS Suffixes for DNS Search. Separated with ";;" 						|
| `add_disk1_size`            	| Size of /dev/sdb in GB 										|
| `add_disk2_size`            	| Size of /dev/sdc in GB 										|
|  `disk_size_vo`		| Size of the voting disks 										|
|  `disk_size_re`		| Size of the redo disks 										|
|  `disk_size_d1`		| Size of the data1 disks 										|
|  `disk_size_d2`		| Size of the data2 disks 										|
|  `disk_size_ex`		| Size of the export disks 										|
| `ip`                  	| IP Address of VM to be defined in vms list								|
| `gateway`               	| Gateway of VM 											|
| `net1_prefix`               	| Netmask in integer notation for the default VNIC in VM. (i.e. the number under the slash in /24) 	|
| `net2_prefix`               	| Netmask in integer notation for the first additional VNIC. (i.e. the number under the slash in /24) 	|
| `net3_prefix`               	| Netmask in integer notation for the second additional VNIC. (i.e. the number under the slash in /24) 	|
| `chef-server_url`		| complete url of the chef server with organization name (eg: https://chef-srv01pvdcco.pvdc.co.charter.com/organizations/video_operations)													     |
| `chef_environment`         	| Name of the environment to create and bootstrap Chef Server in. 					|
| `chef_run_list`            	| Cookbooks to be run for Chef Server bootstrap. If different than the default chtr_common::default and chtr_chef-server::default, the Berksfile must be updated. 										     |
| `chef-user_name` 		| Username to bootstrap the VM to chef server 								|
| `name_start_count` 		| Two digit numeral, usually 01, that gets added in the VM name with prefix and increments 		|
| `chef-attributes_json` 	| this should be blank i.e., "{}" 									|
| `chef-client_version` 	| specify the currently used verions (its "12.19.36" while writing these modules) 			|
| `chef-ssl_verify_mode` 	| mention ":verify_none" 										|
| `chef-skip_client_install` 	| as the chef-client is baked with the VM template, this should be set to true 				|

### Sensitive Variables

It is recommended that passwords/sensitive information is set via environment variable.  Terraform variables are prefixed with `TF_VAR_` 

e.g. the variable vsphere_password can be set with:

    $ export TF_VAR_vsphere_pasword=VerySecret

Note the space between the command prompt and the `export` command.  Commands are prefixed with a space to prevent them from appearing in history.  Even better would be to set using vault.  See `example/set-vars.sh` for how to do that.

In lieu of a secrets database, there is a script in `scripts/set-vars.sh` that will securely prompt for these passwords.

## Provision the shared disks

Perform a `terraform plan -target=module.disk-module-name` and review the changes to be made.
Verify that the plan output matches your requirement

Now, provision the disks using `terraform apply -target=module.disk-module-name`

## Provision the VMs serially

With the disks in place, now go ahead and provision the VMs one after the other.

* Perform a `terraform plan -target=module.vm-module-name.vsphere_virtual_machine.oracle[0]` and review the changes to be made.
  Verify that the plan output matches your requirement
* Now, provision the VM using `terraform apply -target=module.vm-module-name.vsphere_virtual_machine.oracle[0]`

Repeat the above two steps for all the other VMs (Remember to increment the array number).

Note that the module powers off the VMs and you are required to set the disk sharing property on the VMs by editing the respective .vmx file and then power on the VMs.


# Example

This example is for creating two oracle enterprise servers:
```
###create the disks first
terraform plan -target=module.dbho-disk
terraform apply -target=module.dbho-disk

###provision the first VM
terraform plan -target=module.dbho.vsphere_virtual_machine.oracle[0]
terraform apply -target=module.dbho.vsphere_virtual_machine.oracle[0]

###provision the second VM
terraform plan -target=module.dbho.vsphere_virtual_machine.oracle[1]
terraform apply -target=module.dbho.vsphere_virtual_machine.oracle[1]
```
