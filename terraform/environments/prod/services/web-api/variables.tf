variable "tfstate_bucket_name" {
  type        = string
  description = "tfstate bucket name"
}
variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "allowed cidr blocks"
  default     = ["0.0.0.0/0"]

}
