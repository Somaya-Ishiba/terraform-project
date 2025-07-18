output "proxy1_public_ip" {
  value = aws_instance.proxy1.public_ip
}
output "proxy2_public_ip" {
  value = aws_instance.proxy2.public_ip
}
output "backend1_private_ip" {
  value = aws_instance.backend1.private_ip
  
}
output "backend2_private_ip" {
  value = aws_instance.backend2.private_ip
  
}
resource "null_resource" "write_ips" {
  provisioner "local-exec" {
    command = <<EOT
echo "proxy1 ${aws_instance.proxy1.public_ip}" > all-ips.txt
echo "proxy2 ${aws_instance.proxy2.public_ip}" >> all-ips.txt
echo "backend1 ${aws_instance.backend1.private_ip}" >> all-ips.txt
echo "backend2 ${aws_instance.backend2.private_ip}" >> all-ips.txt
EOT
  }

  depends_on = [
    aws_instance.proxy1,
    aws_instance.proxy2,
    aws_instance.backend1,
    aws_instance.backend2
  ]
}
