output "vpc_id" {
  value = "${aws_vpc.terraformDemo.id}"
}

output "subnet_id" {
  value = "${aws_subnet.publicDemo.id}"
}
