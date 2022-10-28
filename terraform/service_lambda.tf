resource "aws_iam_role" "iam_for_lambda" {
  name = "${local.name_prefix}_resolver_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_secretsmanager_secret" "db_connection_string" {
  name = "${local.project}/${local.service}/${local.environment}/db/connection_string"
}

data "aws_secretsmanager_secret_version" "db_connection_string_value" {
  secret_id = data.aws_secretsmanager_secret.db_connection_string.id
}

locals {
  db_connection_string = data.aws_secretsmanager_secret_version.db_connection_string_value.secret_string
}

resource "aws_lambda_function" "resolver_lambda" {
  depends_on = [
    null_resource.resolver_image_push
  ]
  image_uri     = "${aws_ecr_repository.service_ecr.repository_url}@${data.aws_ecr_image.resolver_image.id}"
  function_name = "${local.name_prefix}_resolver"
  role          = aws_iam_role.iam_for_lambda.arn
  package_type  = "Image"
  environment {
    variables = {
      DB_CONNECTION_STRING = local.db_connection_string
    }
  }
}

resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${local.project}/${local.service}/${local.environment}/${aws_lambda_function.resolver_lambda.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_policy" "resolver_logging_policy" {
  name   = "${aws_lambda_function.resolver_lambda.function_name}_logging"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.id
  policy_arn = aws_iam_policy.resolver_logging_policy.arn
}
