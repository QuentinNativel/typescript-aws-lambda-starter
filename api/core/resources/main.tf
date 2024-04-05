locals {
  src_base = "${path.root}/../dist/api/core"
  tmp_base = "${path.root}/../tmp"
  name     = "${var.environment.project_name}-core"
}

resource "aws_lambda_function" "core" {
  architectures = ["arm64"]
  function_name = local.name
  handler       = "handler.main"
  runtime       = "nodejs20.x"
  role          = aws_iam_role.role.arn
  logging_config {
    application_log_level = "INFO"
    log_format            = "JSON"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.logs.name
  }
  depends_on = [
    aws_cloudwatch_log_group.logs,
    aws_iam_role.role,
  ]
  s3_bucket        = aws_s3_object.object.bucket
  s3_key           = aws_s3_object.object.key
  timeout          = 30
  source_code_hash = data.archive_file.file.output_base64sha256

}

data "archive_file" "file" {
  type        = "zip"
  source_dir  = local.src_base
  output_path = "${local.tmp_base}/${local.name}.zip"
}

resource "aws_s3_object" "object" {
  bucket = var.environment.buckets.deployment
  key    = "${local.name}.zip"
  source = data.archive_file.file.output_path
  etag   = filemd5("${data.archive_file.file.output_path}")

}

resource "aws_ssm_parameter" "function_ssm_parameters" {
  for_each = var.function_ssm_parameter_names
  name     = "/projects/${var.environment.project_name}/lambda/${local.name}/${each.value}"
  type     = "SecureString"
  key_id   = data.aws_kms_alias.ssm.arn
  value    = "1"
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/lambda/${local.name}"
  log_group_class   = "STANDARD"
  retention_in_days = 7
}

resource "aws_iam_role" "role" {
  description = "Role for the core lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "policy" {
  name   = "function-permissions"
  role   = aws_iam_role.role.name
  policy = data.aws_iam_policy_document.policy_document.json
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    sid = "writeLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    effect = "Allow"
    resources = [
      "${aws_cloudwatch_log_group.logs.arn}:*"
    ]
  }
  statement {
    sid       = "createLogGroup"
    actions   = ["logs:CreateLogGroup"]
    effect    = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.this.id}:${data.aws_caller_identity.this.id}:*"]
  }
  #   statement {
  #     sid = "workWithSSMParameters"
  #     actions = [
  #       "ssm:GetParameter",
  #       "ssm:PutParameter"
  #     ]
  #     effect    = "Allow"
  #     resources = [for item in aws_ssm_parameter.function_ssm_parameters : item.arn]
  #   }
}
