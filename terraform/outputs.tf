output "vpc_id" {
  value = aws_vpc.main.id
}

output "devops-server_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "devops-server_private_ip" {
  value = aws_instance.jenkins.private_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "devops-server_instance_id" {
  value = aws_instance.jenkins.id
}
