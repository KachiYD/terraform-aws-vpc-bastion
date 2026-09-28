output "alb_dns_name" {
  description = "Public DNS name of the load balancer — hit this in a browser to reach the app"
  value       = aws_lb.load_balancer.dns_name
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host — used to SSH in"
  value       = aws_instance.bastion-host.public_ip
}