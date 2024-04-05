provider "aws" {
  profile = "polars-sandbox-developer"
}

module "core" {
  source = "./core/resources"
  environment = {
    project_name = var.environment.project_name
    buckets = {
      deployment = aws_s3_bucket.deployment.bucket
    }
  }
}

resource "aws_s3_bucket" "deployment" {
  bucket = lower("${var.environment.project_name}-deployment")
}

resource "aws_apigatewayv2_api" "api" {
  name          = var.environment.project_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
  description = "Default stage (i.e., Production mode)"
  default_route_settings {
    throttling_burst_limit = 1
    throttling_rate_limit  = 1
  }
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.logs.arn
    format = jsonencode({
      authorizerError           = "$context.authorizer.error",
      identitySourceIP          = "$context.identity.sourceIp",
      integrationError          = "$context.integration.error",
      integrationErrorMessage   = "$context.integration.errorMessage"
      integrationLatency        = "$context.integration.latency",
      integrationRequestId      = "$context.integration.requestId",
      integrationStatus         = "$context.integration.integrationStatus",
      integrationStatusCode     = "$context.integration.status",
      requestErrorMessage       = "$context.error.message",
      requestErrorMessageString = "$context.error.messageString",
      requestId                 = "$context.requestId",
      routeKey                  = "$context.routeKey",
    })
    #   see for details https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-logging-variables.html
  }
}

resource "aws_apigatewayv2_deployment" "deployment" {
  api_id = aws_apigatewayv2_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_apigatewayv2_integration.core,
      aws_apigatewayv2_route.core_route,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.api.name}"
  log_group_class   = "STANDARD"
  retention_in_days = 7
}

resource "aws_lambda_permission" "invoke-lambda-permission" {
  statement_id  = "allowInvokeFromAPIGatewayRoute"
  action        = "lambda:InvokeFunction"
  function_name = module.core.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/core/*"
}

resource "aws_apigatewayv2_integration" "core" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = module.core.arn

}

resource "aws_apigatewayv2_route" "core_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /core/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.core.id}"
}
