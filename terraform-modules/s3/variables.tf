variable "buckets" {
  type = map(any)
}

variable "tags" {
  type = map(string)
  default = {
    Terraform   = true
    Environment = "dev"
    Owner       = "jetolink"
  }
}
