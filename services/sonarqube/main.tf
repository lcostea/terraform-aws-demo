provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "present-terraform-demo-aws"
    key    = "services/sonarqube/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "present-terraform-demo-aws"
    key    = "vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_security_group" "sonarSecurity" {
  name   = "web"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["79.112.62.30/32", "10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "sonarqube" {
  connection {
    user        = "centos"
    timeout     = "10m"
    type        = "ssh"
    private_key = "${file("${var.public_key_path}")}"
    agent       = "false"
  }

  tags {
    Name    = "Development SonarQube"
    Version = "1.0"
    Type    = "sonarqube"
    Env     = "development"
  }

  associate_public_ip_address = "true"
  instance_type               = "t2.medium"

  ami = "ami-9bf712f4"

  key_name = "terraform-demo-eu-central"

  vpc_security_group_ids = ["${aws_security_group.sonarSecurity.id}"]

  subnet_id = "${data.terraform_remote_state.vpc.subnet_id}"
}

module "ec2-burst-instance-alarms-sonarqube" {
  source                   = "./../../modules/ec2-burst-instance-alarms"
  ec2Id                    = "${aws_instance.sonarqube.id }"
  ec2Name                  = "sonarqube"
  minCreditsThreshold      = "15"
  maxCreditsUsageThreshold = "4"
}
