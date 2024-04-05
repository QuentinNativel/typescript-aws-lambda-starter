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
