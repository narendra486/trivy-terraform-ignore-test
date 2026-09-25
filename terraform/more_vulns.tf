# More intentional misconfigs to push past 10 findings

resource "aws_sqs_queue" "unencrypted" {
  name                    = "trivy-test-queue"
  sqs_managed_sse_enabled = false
}

resource "aws_sns_topic" "unencrypted" {
  name = "trivy-test-topic"
}

resource "aws_cloudtrail" "insecure" {
  name                          = "trivy-test-trail"
  s3_bucket_name                = aws_s3_bucket.public_data.id
  include_global_service_events = false
  is_multi_region_trail         = false
  enable_log_file_validation    = false
  enable_logging                = false
}

resource "aws_iam_account_password_policy" "weak" {
  minimum_password_length        = 6
  require_lowercase_characters   = false
  require_numbers                = false
  require_uppercase_characters   = false
  require_symbols                = false
  allow_users_to_change_password = true
  max_password_age               = 0
  password_reuse_prevention      = 0
}

resource "aws_elb" "insecure" {
  name               = "trivy-test-elb"
  availability_zones = ["us-east-1a"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  access_logs {
    bucket  = aws_s3_bucket.public_data.bucket
    enabled = false
  }
}

resource "aws_launch_configuration" "insecure" {
  name_prefix   = "trivy-test-lc-"
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  associate_public_ip_address = true

  root_block_device {
    encrypted = false
  }

  metadata_options {
    http_tokens = "optional"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_kinesis_stream" "unencrypted" {
  name        = "trivy-test-stream"
  shard_count = 1
  encryption_type = "NONE"
}
