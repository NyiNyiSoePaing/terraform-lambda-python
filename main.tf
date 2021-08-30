provider "aws" {
  region = "ap-southeast-1"
}

# IAM role for  lambda
resource "aws_iam_role" "lambda_role" {
  name               = "iam_role_lambda_function"
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

# IAM policy for  lambda

resource "aws_iam_policy" "lambda_logging" {

  name        = "iam_policy_lambda_logging_function"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Policy Attachment on the role.

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Generates an archive from content

data "archive_file" "default" {
  type        = "zip"
  source_file = "./hello.py"
  output_path = "./python.zip"
}

# Create a lambda function

resource "aws_lambda_function" "lambdafunc" {
  filename      = "./python.zip"
  function_name = "My_Lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "hello.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_iam_role_policy_attachment.policy_attach]
}