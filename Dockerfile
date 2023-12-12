# LTS
FROM jenkins/jenkins:2.426.1-jdk17

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/plugins.txt

USER root
RUN apt update \
    && apt install -qqy apt-transport-https ca-certificates curl gnupg2 software-properties-common 

RUN apt clean

USER jenkins