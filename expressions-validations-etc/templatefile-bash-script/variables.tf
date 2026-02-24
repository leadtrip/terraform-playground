variable "environment" {
  type = string
}

variable "enable_extra_message" {
  type    = bool
  default = false
}

variable "extra_message" {
  type    = string
  default = ""
}