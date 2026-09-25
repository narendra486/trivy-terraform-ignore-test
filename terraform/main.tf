# Public S3 bucket — multiple misconfigs (ACL, encryption, logging, versioning)
resource "aws_s3_bucket" "public_data" {
  bucket = "trivy-test-public-data-bucket"
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "public_data" {
  bucket = aws_s3_bucket.public_data.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Unencrypted EBS volume
resource "aws_ebs_volume" "unencrypted" {
  availability_zone = "us-east-1a"
  size              = 40
  encrypted         = false
}

# Wide-open security group (SSH + all traffic from internet)
resource "aws_security_group" "wide_open" {
  name        = "trivy-test-wide-open"
  description = "Intentionally insecure SG for Trivy demo"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "All traffic from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Publicly accessible, unencrypted RDS
resource "aws_db_instance" "public_db" {
  identifier                   = "trivy-test-public-db"
  engine                       = "mysql"
  engine_version               = "8.0"
  instance_class               = "db.t3.micro"
  allocated_storage            = 20
  username                     = "admin"
  password                     = "SuperSecretPassword123!"
  publicly_accessible          = true
  storage_encrypted            = false
  skip_final_snapshot          = true
  backup_retention_period      = 0
  auto_minor_version_upgrade   = false
  deletion_protection          = false
  performance_insights_enabled = false
}

# EC2 without IMDSv2 / detailed monitoring
resource "aws_instance" "legacy" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  metadata_options {
    http_tokens = "optional"
  }

  root_block_device {
    encrypted = false
  }

  monitoring = false
}
