variable "ssh_key_pair_name" {
  description = "The name of the AWS Key pair to use to connect to the Factorio server"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The instance type to use for the Factorio server"
  type        = string
  default     = "t3.medium"
}
