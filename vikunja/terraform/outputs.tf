output "front" {
  value = [
    {
        "private_ip" = aws_instance.front[*].private_ip
        "public_ip" = aws_instance.front[*].public_ip
        "private_dns" = aws_instance.front[*].private_dns
        "public_dns"   = aws_instance.front[*].public_dns
    }
    ]
}

output "api" {
  value = [
    {
        "private_ip" = aws_instance.api[*].private_ip
        "public_ip" = aws_instance.api[*].public_ip
        "private_dns" = aws_instance.api[*].private_dns
        "public_dns"   = aws_instance.api[*].public_dns
    }
    ]
}