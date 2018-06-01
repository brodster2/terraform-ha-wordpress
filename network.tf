resource "aws_vpc" "wordpressVpc" {
  cidr_block = "10.0.0.0/22"

  tags {
    name        = "WordpressTest"
    generatedBy = "Terraform"
  }
}

### Subnets
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.wordpressVpc.id}"
  cidr_block              = "10.0.0.0/25"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count      = 2
  vpc_id     = "${aws_vpc.wordpressVpc.id}"
  cidr_block = "${element(var.privateSubnetList, count.index)}"
}

### Gateways
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.wordpressVpc.id}"
}

resource "aws_nat_gateway" "natGw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"

  depends_on = ["aws_internet_gateway.gw"]
}

### Elastic IP (Required for NAT Gateway)
resource "aws_eip" "nat" {
  vpc = true
}

### Route Tables

resource "aws_route_table" "publicRt" {
  vpc_id = "${aws_vpc.wordpressVpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table" "privateRt" {
  vpc_id = "${aws_vpc.wordpressVpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natGw.id}"
  }
}
