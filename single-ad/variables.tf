variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}
variable "compartment_ocid" {}

variable "AD" {
  description = "Pick up the AD you want to deploy"
  default     = "1"
}

# VCN variables
variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "vcn_name_label" {
  description = "VCN display name"
  default     = "sap-vcn"
}

variable "vcn_dns_label" {
  description = "VCN DNS label"
  default     = "sap"
}

# Bastion Public Subnets Variables
variable "bastion_subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "bastion_subnet_label" {
  default = "bastion"
}

# SAP Application Private Subnet 
variable "sap_subnet_cidr_block" {
  default = "10.0.2.0/24"
}

variable "sap_subnet_label" {
  default = "sapnet"
}

# Database Private Subnet 
variable "database_subnet_cidr_block" {
  default = "10.0.3.0/24"
}

variable "database_subnet_label" {
  default = "dbnet"
}

# FSS Private Subnet 
variable "fss_subnet_cidr_block" {
  default = "10.0.4.0/24"
}

variable "fss_subnet_label" {
  default = "fssnet"
}

# OS Images
variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.5"
}

variable "WinInstanceOS" {
  description = "Operating system for compute instances"
  default     = "Windows"
}

variable "WinInstanceOSVersion" {
  description = "Operating system version for all windows instances"
  default     = "Server 2012 R2 Standard"
}

# Bastion Linux Instance Variables
variable "bastion_linux_display_name" {
  default = "Bastion-Linux"
}

variable "bastion_linux_hostname" {
  default = "bastion-lnx"
}

variable "bastion_linux_instance_shape" {
  default = "VM.Standard2.1"
}

variable "bastion_linux_boot_volume_size" {
  description = "boot volume size in GB"
  default     = "50"
}

# Bastion Windows Instance Variables
variable "bastion_windows_display_name" {
  default = "Bastion-Win"
}

variable "bastion_windows_hostname" {
  default = "bastion-win"
}

variable "bastion_windows_instance_shape" {
  default = "VM.Standard2.4"
}

variable "bastion_windows_boot_volume_size" {
  description = "boot volume size in GB"
  default     = "300"
}

# SAP Windows Instance Variables
variable "sap_windows_display_name" {
  default = "SAP-Win"
}

variable "sap_windows_hostname" {
  default = "sap-win"
}

variable "sap_windows_instance_shape" {
  default = "VM.Standard2.8"
}

variable "sap_windows_boot_volume_size" {
  description = "boot volume size in GB"
  default     = "300"
}

# SAP Linux Instance Variables
variable "sap_linux_display_name" {
  default = "SAP-Linux"
}

variable "sap_linux_hostname" {
  default = "sap-lnx"
}

variable "sap_linux_instance_shape" {
  default = "VM.Standard2.8"
}

variable "sap_linux_boot_volume_size" {
  description = "boot volume size in GB"
  default     = "500"
}

# FSS Variables

variable "fss_sap_file_system_display_name" {
  default = "sap_fss"
}

variable "fss_sap_mount_target_display_name" {
  default = "sap_fss_mount_target"
}

variable "fss_sap_export_set_name" {
  default = "export set for mount target"
}

variable "export_path_fss_sap" {
  default = "/sap/fss"
}

variable "max_byte" {
  default = 500843202333
}

variable "max_files" {
  default = 223442
}

locals {
  sap_fss_mount_target_ip_address = "${lookup(data.oci_core_private_ips.ip_sap_fss_mount_target.private_ips[0], "ip_address")}"
}
