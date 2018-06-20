# Create Elastic File System and Mount Targets
resource "aws_efs_file_system" "demoWP" {
  tags {
    Name = "Demo WP"
  }
}

resource "aws_efs_mount_target" "demoWP" {
  count           = 2
  file_system_id  = "${aws_efs_file_system.demoWP.id}"
  subnet_id       = "${element("${aws_subnet.private.*.id}", count.index)}"
  security_groups = ["${aws_security_group.nfsIngressSg.id}"]
}

resource "aws_security_group" "nfsIngressSg" {
  name        = "efs-mount-target-NFS"
  description = "Allow NFS port 2049 ingress"
  vpc_id      = "${aws_vpc.wordpressVpc.id}"

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    self      = true  # This will allow ingress between the ec2 instances and mount targets when this sg is attached to both
  }
}
