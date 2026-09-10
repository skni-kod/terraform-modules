variable "name" {
  type = string
}

variable "target_node" {
  type = string
}

variable "vmid" {
  type = number
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "cores" {
  type = number
}

variable "memory" {
  type = number
}

variable "datastore_id" {
  type    = string
  default = "local-lvm"
}

variable "disk_size" {
  type = number
}

variable "cloned_vm_id" {
  type = number
}

variable "network_bridge" {
  type = string
}

variable "ip_address" {
  type = string
}

variable "gateway" {
  type = string
}

variable "ci_user" {
  type = string
}

variable "ssh_public_key" {
  type = string
}
