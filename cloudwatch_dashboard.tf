resource "aws_cloudwatch_dashboard" "petshop_dashboard" {
  dashboard_name = "PetshopDashboardV8_Full"

  dashboard_body = <<EOF
{"widgets": [{"type": "metric", "x": 0, "y": 0, "width": 24, "height": 6, "properties": {"title": "EC2 \u2013 CPU & Network", "region": "us-east-1", "view": "timeSeries", "metrics": [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${aws_autoscaling_group.petshop_asg.name}", {"stat": "Average"}], [".", "NetworkIn", ".", ".", {"stat": "Sum"}], [".", "NetworkOut", ".", ".", {"stat": "Sum"}], [".", "DiskReadOps", ".", ".", {"stat": "Sum"}], [".", "DiskWriteOps", ".", ".", {"stat": "Sum"}]], "period": 300}}]}
EOF
}
