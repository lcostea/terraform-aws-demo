# terraform refactor

terraform state list

terraform state mv -state-out=.\..\worker\terraform.tfstate module.ec2-burst-instance-alarms-worker.aws_cloudwatch_metric_alarm.lowCredits  module.ec2-burst-instance-alarms-worker.aws_cloudwatch_metric_alarm.lowCredits

terraform state mv -state-out=".\..\worker\terraform.tfstate" aws_security_group.workerSecurity aws_security_group.workerSecurity


https://github.com/hashicorp/terraform/issues/10481