#!/bin/bash
set -euxo pipefail

# Log user-data output to a file for troubleshooting
exec > >(tee /var/log/jenkins-install.log | logger -t jenkins-install -s 2>/dev/console) 2>&1

# Update OS packages
sudo yum update -y

# Install Java 17 (required by modern Jenkins) + utilities
sudo yum install -y java-17-amazon-corretto wget

# Make sure Java 17 is the default
sudo alternatives --set java /usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/java || true
java -version

# Add Jenkins repo + import the current key
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install and start Jenkins
sudo yum install -y jenkins
sudo systemctl enable --now jenkins

# Quick health check (won't fail the whole script if Jenkins needs a moment)
sudo systemctl status jenkins --no-pager -l || true
