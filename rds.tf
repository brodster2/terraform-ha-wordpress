# Create managed mysql server in RDS
resource "aws_db_instance" "wordpress" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = "testExample"
  password               = "${var.rds_root_password}"
  port                   = "3306"
  name                   = "wp_db"
  parameter_group_name   = "default.mysql5.7"
  maintenance_window     = "Sun:00:00-Sun:01:00"
  publicly_accessible    = true
  vpc_security_group_ids = ["${aws_security_group.wordpressRdsSg.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.wordpressDb.id}"
}

# Database subnet group
resource "aws_db_subnet_group" "wordpressDb" {
  subnet_ids = ["${aws_subnet.private.*.id}"]
}

# Database security groups
resource "aws_security_group" "wordpressRdsSg" {
  name        = "wordpress-rds-sg"
  description = "Only allow ingress from wordpress EC2 instances on port 3306"
  vpc_id      = "${aws_vpc.wordpressVpc.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = "${var.private_subnet_cidr_list}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
