output "jenkins_public_ip" {
  description = "Public IP of Jenkins Instance"
  value       = aws_instance.jenkins.public_ip
}

output "sonarqube_public_ip" {
  description = "Public IP of SonarQube Instance"
  value       = aws_instance.sonarqube.public_ip
}

output "ansible_public_ip" {
  description = "Public IP of Ansible Instance"
  value       = aws_instance.ansible.public_ip
}