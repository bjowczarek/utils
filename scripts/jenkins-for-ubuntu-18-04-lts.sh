#!/bin/bash
#
# Instalation of Jenkins faces a few time consuming issues.
# The most odd is related to installation of deamon package which is not available by default.
# Script has to be run with sudo.
#
#
# prerequisites:
# entries of /etc/apt/sources.list modified by adding "restricted universe" at the end of each line
# ex:
# deb http://archive.ubuntu.com/ubuntu bionic main restricted universe
# deb http://archive.ubuntu.com/ubuntu bionic-security main restricted universe
# deb http://archive.ubuntu.com/ubuntu bionic-updates main restricted universe
#
#
add-apt-repository ppa:webupd8team/java
apt update
apt install oracle-java8-installer
apt install oracle-java8-set-default
javac -version
echo "###################################"
echo "####### JAVA versions #############"
echo "###################################"
update-java-alternatives -l
echo "###################################"
echo "JAVA_HOME=\"/usr/lib/jvm/java-8-oracle\"" >> /etc/environment
source /etc/environment
cd /tmp && wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
echo 'deb https://pkg.jenkins.io/debian-stable binary/' | tee -a /etc/apt/sources.list.d/jenkins.list
apt update
apt install daemon
apt install jenkins
#### check
systemctl stop jenkins.service
systemctl start jenkins.service
systemctl enable jenkins.service
ufw allow 8080
### display password
echo "###################################"
echo "######### PASSWORD ################"
echo "###################################"
cat /var/lib/jenkins/secrets/initialAdminPassword
echo "###################################"
