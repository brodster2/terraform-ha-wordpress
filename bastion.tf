# Create bastion host to restrict ssh access to private app servers
resource "aws_instance" "bastion" {
  ami                    = "ami-921423eb"                          # Amazon linux LTS
  instance_type          = "t2.micro"
  key_name               = "${var.bastion_host_key}"
  monitoring             = true
  subnet_id              = "${aws_subnet.public.id}"
  vpc_security_group_ids = ["${aws_security_group.bastionSsh.id}"]

  tags {
    Name = "Wordpress bastion host"
  }
}

resource "aws_security_group" "bastionSsh" {
  name        = "bastion-ssh-ingress"
  description = "To be attached to the bastion host. Allows ingress to port 22 form outside of vpc and egress to app server in private subnets."
  vpc_id      = "${aws_vpc.wordpressVpc.id}"

  ingress {
    to_port     = 22
    from_port   = 22
    protocol    = "tcp"
    cidr_blocks = "${var.trusted_ssh_cidrs}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "bastionEip" {
  vpc        = true
  instance   = "${aws_instance.bastion.id}"
  depends_on = ["aws_internet_gateway.gw"]

  tags {
    Name = "Bastion EIP"
  }
}
