# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket        = "my-bucket-2025-new2"
  force_destroy = true
  tags = {
    Environment = "prod"
    Name        = "My bucket"
  }

}
# SQS Queue
# ---------------------------
resource "aws_sqs_queue" "myqueue" {
  name = "my-s3-events-queue"
}

# Create an IAM role

resource "aws_iam_role" "lambda_s3_role" {
  name = "lambda_s3_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

}

# Attach the AWSLambdaBasicExecutionRole policy to the IAM role

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda_s3_policy"
  role = aws_iam_role.lambda_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow",
        Action   = ["sqs:SendMessage"],
        Resource = aws_sqs_queue.myqueue.arn
      }

    ]
  })
}


# Create a Lambda function

resource "aws_lambda_function" "s3_to_sqs" {
  function_name    = "s3_to_sqs"
  runtime          = "python3.9"
  filename         = "lambda.zip"
  role             = aws_iam_role.lambda_s3_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.myqueue.id
    }

  }

}

#allow S3 to invoke the Lambda function

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_sqs.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.my_bucket.arn

}

# Create an S3 bucket notification to trigger the Lambda function on object creation

resource "aws_s3_bucket_notification" "bucket_notify" {
  bucket = aws_s3_bucket.my_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_sqs.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]

}

output "s3_bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

output "lambda_function_arn" {
  value = aws_lambda_function.s3_to_sqs.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.myqueue.id
}
