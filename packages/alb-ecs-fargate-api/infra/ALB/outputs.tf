output "target_group_arn" {
    description = "ARN of the ALB target group"
    value       = aws_lb_target_group.kata1_tg.arn
}

output "alb_listener_arn" {
    description = "ARN of the ALB HTTP listener"
    value       = aws_lb_listener.kata1_http.arn
}

output "alb_security_group_id" {
    description = "Security Group ID of the ALB"
    value       = aws_security_group.kata1_alb_sg.id
}