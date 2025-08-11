variable "region" {
  type = string
}

variable "apps" {
  type = map(object({
    branch       = string
    buildspec    = string
    repo_name    = string
    bucket_name  = string
    service_name = optional(string)
  }))
  default     = {}
  description = "App configurations"
}

variable "github_connection" {
  type = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Default tags for resources"
}
