### Security group for alb
resource "aws_security_group" "AlbSg" {
  name        = "wordpress-http-lb"
  description = "Allow http inbound"
  vpc_id      = "${aws_vpc.wordpressVpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "wordpress-http-lb"
  }
}

### Application Load Balancer
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.4.0"

  load_balancer_name = "wordpress-alb"
  security_groups    = ["${aws_security_group.AlbSg.id}"]
  subnets            = ["${aws_subnet.private.*.id}"]
  vpc_id             = "${aws_vpc.wordpressVpc.id}"

  http_tcp_listeners_count = 1
  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"

  target_groups_count = 1
  target_groups       = "${list(map("name", "wordpress-tg", "backend_protocol", "HTTP", "backend_port", "8080"))}"

  log_bucket_name     = "${aws_s3_bucket.wordpressLogging.id}"
  log_location_prefix = "alb/access"
}

### S3 bucket for logs
resource "aws_s3_bucket" "wordpressLogging" {
  bucket = "wordpress-lb-logging"
  region = "eu-west-1"

  lifecycle_rule {
    id      = "wp-logs"
    enabled = true

    prefix = "alb/access"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "albLogging" {
  bucket = "${aws_s3_bucket.wordpressLogging.id}"

  policy = <<POLICY
{
  "Id": "Policy1527862588928",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1527862562861",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.wordpressLogging.arn}/*"
      ],
      "Principal": {
        "AWS": [
          "156460612806"
        ]
      }
    }
  ]
}
POLICY
}
