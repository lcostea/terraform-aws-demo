variable "ec2Id" {
  type = "string"
}

variable "ec2Name" {
  type = "string"
}

variable "minCreditsThreshold" {
  type = "string"
}

variable "maxCreditsUsageThreshold" {
  type = "string"
}

variable "alarmAction" {
  type    = "string"
  default = "arn:aws:sns:eu-central-1:339739779302:TechnicalSupport"
}

resource "aws_cloudwatch_metric_alarm" "highCpu" {
  alarm_name                = "${var.ec2Name} (${var.ec2Id}) High CPU"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "4"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "75"
  alarm_description         = "Alert on ${var.ec2Name} High CPU"
  alarm_actions             = ["${var.alarmAction}"]
  insufficient_data_actions = []

  dimensions = {
    InstanceId = "${var.ec2Id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "lowCredits" {
  alarm_name                = "${var.ec2Name} (${var.ec2Id}) Low Credits"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUCreditBalance"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "${var.minCreditsThreshold}"
  alarm_description         = "Alert on ${var.ec2Name} Low number of credits"
  alarm_actions             = ["${var.alarmAction}"]
  insufficient_data_actions = []

  dimensions = {
    InstanceId = "${var.ec2Id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "highCreditUsage" {
  alarm_name                = "${var.ec2Name} (${var.ec2Id}) Too High Credit Usage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "3"
  metric_name               = "CPUCreditUsage"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "${var.maxCreditsUsageThreshold}"
  alarm_description         = "Alert on ${var.ec2Name} Too High Credit Usage"
  alarm_actions             = ["${var.alarmAction}"]
  insufficient_data_actions = []

  dimensions = {
    InstanceId = "${var.ec2Id}"
  }
}
