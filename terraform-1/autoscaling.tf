
# Creating the autoscaling launch configuration that contains AWS EC2 instance details

resource "aws_launch_configuration" "aws_autoscale_conf" {
  name          = "web_config"
  image_id      = "ami-08a52ddb321b32a8c"
  instance_type = "t2.micro"
   key_name = "tf_key"
}

# Creating the autoscaling group within us-east-1a availability zone

resource "aws_autoscaling_group" "mygroup" {

  availability_zones        = ["us-east-1a"]
  name                      = "autoscalegroup"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 2
  health_check_grace_period = 100
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.aws_autoscale_conf.name
}
# Creating the autoscaling schedule of the autoscaling group

resource "aws_autoscaling_schedule" "mygroup_schedule" {

  scheduled_action_name  = "autoscalegroup_action"
  min_size               = 1
  max_size               = 2
  desired_capacity       = 1
  start_time             = "2023-08-14T20:00:00Z"
  autoscaling_group_name = aws_autoscaling_group.mygroup.name
}

# Creating the autoscaling policy of the autoscaling group

resource "aws_autoscaling_policy" "mygroup_policy" {
  name                   = "autoscalegroup_policy"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.mygroup.name
}

#deploy cloudwatch alarm

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {

  alarm_name = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "10"
  alarm_actions = [
        "${aws_autoscaling_policy.mygroup_policy.arn}"
    ]
dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.mygroup.name}"
  }
}