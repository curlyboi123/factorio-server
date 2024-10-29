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

variable "spot_price" {
  description = "The maximum amount you are willing to pay for the spot instance"
  type        = string
  default     = "0.025"
}
