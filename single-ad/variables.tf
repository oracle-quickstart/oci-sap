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

# SAP Web Dispatcher Public Subnet 
variable "sap_web_subnet_cidr_block" {
  default = "10.0.5.0/24"
}

variable "sap_web_subnet_label" {
  default = "sapwebnet"
}

# SAP Router Private Subnet 
variable "sap_route_subnet_cidr_block" {
  default = "10.0.6.0/24"
}

variable "sap_route_subnet_label" {
  default = "saprouternet"
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

# Load Balancer Private Subnet 
variable "lb_subnet1_cidr_block" {
  default = "10.0.7.0/24"
}

variable "lb_subnet1_label" {
  default = "lbsubnet1"
}

variable "lb_subnet2_cidr_block" {
  default = "10.0.8.0/24"
}

variable "lb_subnet2_label" {
  default = "lbsubnet2"
}

# Load Balancer Shape

variable "lb_shape" {
  default = "100Mbps"
}

variable "lb_display_name" {
  default = "SAP_Load_Balancer"
}

variable "lb_backend_set_name" {
  default = "web_dispatcher_backend"
}

variable "lb_backend_listener_name" {
  default = "lb_listener_sap"
}

# OS Images
variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.6"
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

# SAP Router Instance Variables
variable "sap_router_display_name" {
  default = "SAP-Router"
}

variable "sap_router_hostname" {
  default = "sap-router"
}

variable "sap_router_instance_shape" {
  default = "VM.Standard2.1"
}

variable "sap_router_boot_volume_size" {
  description = "boot volume size in GB"
  default     = "300"
}

# SAP Web Dispatcher Variables
variable "sap_web_dis_display_name" {
  default = "SAP-Web-Dispatcher"
}

variable "sap_web_dis_hostname" {
  default = "sap-web-dis"
}

variable "sap_web_dis_instance_shape" {
  default = "VM.Standard2.1"
}

variable "sap_web_dis_boot_volume_size" {
  description = "boot volume size in GB"
  default     = "300"
}

# SAP Linux Instance Variables
variable "sap_linux_display_name" {
  default = "SAP-Linux-App-Tier"
}

variable "sap_linux_hostname" {
  default = "sap-lnx-app"
}

variable "sap_linux_instance_shape" {
  default = "VM.Standard2.4"
}

variable "sap_linux_boot_volume_size" {
  description = "boot volume size in GB"
  default     = "500"
}

# DB Linux Instance Variables
variable "db_linux_display_name" {
  default = "DB-Linux-App-Tier"
}

variable "db_linux_hostname" {
  default = "sapdb"
}

variable "db_linux_instance_shape" {
  default = "VM.DenseIO2.8"
}

variable "db_linux_boot_volume_size" {
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
  default = "/sapmnt"
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

# SAP App Block and Swap Volumes

variable "sap_app_block_display_name" {
  default = "sap_app_bv"
}

variable "sap_app_bv_size" {
  default = "150"
}

variable "sap_app_block_swap_display_name" {
  default = "sap_app_swap_bv"
}

variable "sap_app_swap_bv_size" {
  default = "96"
}

# SAP DB Block and Swap Volumes

variable "sap_db_block_swap_display_name" {
  default = "sap_db_swap_bv"
}

variable "sap_swap_db_bv_size" {
  default = "96"
}
