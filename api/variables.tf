variable "environment" {
  description = "Environment information"
  type = object({
    project_name = string
  })
}

variable "supabase_url" {
  description = "The Supabase URL"
  type        = string
}
