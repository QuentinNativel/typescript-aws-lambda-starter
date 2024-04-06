variable "environment" {
  description = "Environment information"
  type = object({
    project_name = string
    buckets = object({
      deployment = string
    })
  })
}

variable "function_ssm_parameter_names" {
  description = "A set of SSM parameter names to be precreated for the function (env variables will be precreated as well)"
  type        = set(string)
  default     = []
}

variable "supabase_url_parameter_name" {
  description = "The name of the SSM parameter for the Supabase URL"
  type        = string
}
variable "supabase_url_parameter_arn" {
  description = "The ARN of the SSM parameter for the Supabase URL"
  type        = string
}
