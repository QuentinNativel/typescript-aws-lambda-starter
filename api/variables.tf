variable "environment" {
  description = "Environment information"
  type = object({
    project_name = string
  })
}
