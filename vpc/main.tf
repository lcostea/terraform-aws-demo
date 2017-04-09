provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "present-terraform-demo-aws"
    key    = "vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_vpc" "terraformDemo" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "Terraform-Demo"
  }
}

resource "aws_subnet" "publicDemo" {
  vpc_id                  = "${aws_vpc.terraformDemo.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags {
    Name = "Terraform-Public-Demo"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.terraformDemo.id}"

  tags {
    Name = "Terraform-Demo-GW"
  }
}

resource "aws_route_table" "publicRoute" {
  vpc_id = "${aws_vpc.terraformDemo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Terraform-Demo-Public-Route"
  }
}

resource "aws_main_route_table_association" "mainRoute" {
  vpc_id         = "${aws_vpc.terraformDemo.id}"
  route_table_id = "${aws_route_table.publicRoute.id}"
}
