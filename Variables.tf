# Azure Options
variable "azure_region" {
  default     = "centralus" # Use region shortname here as it's interpolated into the URLs
  description = "The location/region where the resources are created."
}
variable "azure_rg_name" {
  default = "lab" # This will get a unique timestamp appended
  description = "Specify the name of the new resource group"
}

# Shared Options
variable "username" {
  default = "chef"
  description = "Admin username for all VMs"
}

variable "password" {
  default = "C0d3c4n!"
  description = "Admin password for all VMs"
}

variable "vm_size" {
  default = "Standard_D4S_v3"
  description = "Specify the VM Size"
}

variable "source_address_prefix" {
  default = "*"
  description = "Specify source prefix i.e. 1.2.3.4/24. This restricts the network security group so only your systems can remotely access the resources. Prevents resources from being exposed directly to the Internet."
}

variable "count" {
  default = "1"
  description = "Specify the number of student workstations required"
}

variable "image_name" {
  description = "Specify the name of the desired image for the new VM's"
}

variable "image_rg_name" {
  description = "Specify the resource group that contains the desired image"
}


////////////////////////////////
// Required Tags

variable "tag_customer" {
  description = "tag_customer is the customer tag which will be added to Azure"
}

variable "tag_project" {
  description = "tag_project is the project tag which will be added to Azure"
}

variable "tag_dept" {
  description = "tag_dept is the department tag which will be added to Azure"
}

variable "tag_contact" {
  description = "tag_contact is the contact tag which will be added to Azure"
}

variable "tag_application" {
  default = "compliance-workshop"
  description = "tag_application is the application tag which will be added to Azure"
}

variable "tag_ttl" {
  default = 4
  description = "Time, in hours, the environment should be allowed to live"
}