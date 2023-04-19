locals {
  cluster_name_prod    = "production_cluster"
  cluster_name_test    = "test_cluster"
  region               = "eu-central-1"
  stage                = "testing"
  dirks_sns_topic_name = "dirks-updates-topic"
  is_true              = true
  # node_count   = 3 not used anymore, or?
  multi_az = false
  tags = {
    env     = "testing",
    project = "production"
  }
}

data "aws_iam_policy_document" "lambda_permissions_for_manu" {

  # "statement", is not just an arbitrary name it is a placeholder for the (block type) statement {...}
  dynamic "statement" {
    content {
      sid = "sqsSend"
      actions = [
        "sqs:SendMessage",
        "sqs:SendMessageBatch",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      resources = [
        var.dsn_arn
      ]
    }
  }

  statement {
    sid = "dynamodb"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid = "snsSend"
    actions = [
      "sns:Publish"
    ]
    resources = ["*"]
  }
}

## SNS Topics for Dirk

resource "aws_sns_topic" "sns_topic_1" {
  name = local.dirks_sns_topic_name
}

resource "aws_sqs_queue" "dirks_queue" {
  count                       = var.create_dead_letter_queue ? 1 : 0
  name                        = "dirks-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}

resource "aws_sns_topic" "sns_topic_2" {
  count = 1
  name  = var.dirks_sns_topic_name
}

resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic"
}

## S3 for Manuela

resource "aws_s3_bucket" "example" {
  bucket = "manus-bucket"

  tags = {
    Name        = "Manus bucket"
    Environment = "Dev"
  }
}

resource "aws_iam_policy" "policy" {
  name        = "manus_policy"
  path        = "/"
  description = "Will be added to Manus account via console"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
