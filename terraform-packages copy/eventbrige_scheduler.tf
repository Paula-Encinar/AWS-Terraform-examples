resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name        = "daily_schedule"
  description = "Scheduled rule for running Lambda at 16:05"

  schedule_expression = "cron(00 12 * * ? *)"  # Cron expression for 16:05 every day
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.terraform_lambda_func.arn
}