provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "present-terraform-demo-aws"
    key    = "services/web/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_security_group" "webSecurity" {
  name   = "web"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["79.112.99.75/32", "10.0.1.0/24"]
  }

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
}

resource "aws_instance" "web" {
  connection {
    user        = "centos"
    timeout     = "10m"
    type        = "ssh"
    private_key = "${file("${var.public_key_path}")}"
    agent       = "false"
  }

  tags {
    Name    = "Production Web App 1"
    Version = "1.0"
    Type    = "web"
    Env     = "production"
  }

  associate_public_ip_address = "true"
  instance_type               = "t2.small"

  ami = "ami-9bf712f4"

  key_name = "terraform-demo-eu-central"

  vpc_security_group_ids = ["${aws_security_group.webSecurity.id}"]

  subnet_id = "${var.subnet_id}"
}

module "ec2-burst-instance-alarms-web" {
  source                   = "./../../modules/ec2-burst-instance-alarms"
  ec2Id                    = "${aws_instance.web.id }"
  ec2Name                  = "ansible_controller"
  minCreditsThreshold      = "10"
  maxCreditsUsageThreshold = "3"
}
