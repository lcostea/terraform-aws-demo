provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "present-terraform-demo-aws"
    key    = "services/ansible/terraform.tfstate"
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

resource "aws_security_group" "ansible_controller" {
  name   = "ansible_controller"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["79.112.62.30/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ansible_controller" {
  connection {
    user        = "ec2-user"
    timeout     = "10m"
    type        = "ssh"
    private_key = "${file("${var.public_key_path}")}"
    agent       = "false"
  }

  tags {
    Name    = "ansible_controller"
    Version = "2.3"
    Type    = "Ansible"
    Env     = "Production"
  }

  associate_public_ip_address = "true"
  instance_type               = "t2.nano"

  ami = "ami-af0fc0c0"

  key_name = "terraform-demo-eu-central"

  vpc_security_group_ids = ["${aws_security_group.ansible_controller.id}"]

  subnet_id = "${data.terraform_remote_state.vpc.subnet_id}"

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install epel-release",
      "sudo yum -y install python-pip python-devel gcc git libffi-devel openssl-devel",
      "sudo `which pip` install --upgrade pip",
      "sudo `which pip` install ansible 'pywinrm>=0.1.1' boto",
      "sudo yum -y install krb5-devel krb5-libs krb5-workstation",
      "sudo `which pip` install kerberos requests-kerberos",
      "sudo `which pip` install --upgrade setuptools",
      "sudo mkdir /github",
      "cd /github",
      "sudo git clone https://github.com/lcostea/ansible_install.git",
    ]
  }
}

module "ec2-burst-instance-alarms-ansible" {
  source                   = "./../../modules/ec2-burst-instance-alarms"
  ec2Id                    = "${aws_instance.ansible_controller.id }"
  ec2Name                  = "ansible_controller"
  minCreditsThreshold      = "10"
  maxCreditsUsageThreshold = "3"
}
