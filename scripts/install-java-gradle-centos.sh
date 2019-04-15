echo "Installing Java 8.."
  cd /opt/
  wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz"
  tar xzf jdk-8u131-linux-x64.tar.gz
  cd /opt/jdk1.8.0_131/
  alternatives --install /usr/bin/java java /opt/jdk1.8.0_131/bin/java 2
  alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_131/bin/jar 2
  alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_131/bin/javac 2
  alternatives --set jar /opt/jdk1.8.0_131/bin/jar
  alternatives --set javac /opt/jdk1.8.0_131/bin/javac
  mkdir -p /etc/profile.d && touch /etc/profile.d/java.sh
  echo 'export JAVA_HOME=/opt/jdk1.8.0_131' >> /etc/profile.d/java.sh
  echo 'export PATH=${JAVA_HOME}/bin:${PATH}' >> /etc/profile.d/java.sh
  chmod +x /etc/profile.d/java.sh
  source /etc/profile.d/java.sh
#!/bin/bash

  echo "Java Version: "
  java -version

  echo "Installing Gradle 5.."
  wget https://services.gradle.org/distributions/gradle-5.0-bin.zip -P /tmp
  unzip -d /opt/gradle /tmp/gradle-5.0-bin.zip
  mkdir -p /etc/profile.d && touch /etc/profile.d/gradle.sh
  echo 'export GRADLE_HOME=/opt/gradle/gradle-5.0' >> /etc/profile.d/gradle.sh
  echo 'export PATH=${GRADLE_HOME}/bin:${PATH}' >> /etc/profile.d/gradle.sh
  chmod +x /etc/profile.d/gradle.sh
  source /etc/profile.d/gradle.sh

  echo "Gradle Version: "
  gradle -v