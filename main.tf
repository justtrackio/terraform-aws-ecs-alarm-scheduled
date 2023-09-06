locals {
  alarm_topic_arn = var.alarm_topic_arn != null ? var.alarm_topic_arn : "arn:aws:sns:${module.this.aws_region}:${module.this.aws_account_id}:${module.this.environment}-alarms"
}

module "cloudwatch_label" {
  source  = "justtrackio/label/null"
  version = "0.26.0"

  delimiter   = "/"
  label_order = var.label_orders.cloudwatch

  context = module.this.context
}


resource "aws_cloudwatch_metric_alarm" "default" {
  count = module.this.enabled ? 1 : 0

  alarm_name          = "${module.this.id}-app-error"
  alarm_description   = var.alarm_description
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  metric_name         = "error"
  namespace           = module.cloudwatch_label.id
  period              = var.period
  statistic           = "Sum"
  threshold           = var.threshold
  treat_missing_data  = "breaching"

  alarm_actions = [local.alarm_topic_arn]
  ok_actions    = [local.alarm_topic_arn]

  tags = module.this.tags
}
