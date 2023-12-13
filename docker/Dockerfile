# LTS
FROM jenkins/jenkins:2.426.1-alpine-jdk21

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/plugins.txt

USER root
RUN apk update \
    && apk add --no-cache -q ca-certificates curl gnupg \
    && apk upgrade \
    && rm -rf /var/cache/apk/*

USER jenkins