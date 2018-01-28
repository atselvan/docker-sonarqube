FROM openjdk:8 

MAINTAINER Allan Selvan <allantony2008@gmail.com>
LABEL authors="Allan Selvan <allantony2008@gmail.com>"
LABEL version="5.6.6"
LABEL description="Docker container for Sonarqube"

ADD VERSION .

ENV SONAR_VERSION='5.6.6' \
    SONARQUBE_HOME=/appl/sonarqube \
    # Database configuration
    SONARQUBE_JDBC_USERNAME=sonarqube \
    SONARQUBE_JDBC_URL=jdbc:mysql://mysql:3306/sonarqube?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance

# Http port
EXPOSE 9000

RUN mkdir /appl

RUN set -x \
    && cd /appl \
    && curl -o sonarqube.zip -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip \
    && unzip sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sonarqube \
    && rm sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/*

RUN cd $SONARQUBE_HOME/extensions/plugins \
    && curl -o sonar-ldap-plugin-2.1.0.507.jar -fSL https://sonarsource.bintray.com/Distribution/sonar-ldap-plugin/sonar-ldap-plugin-2.1.0.507.jar \
    && curl -o sonar-web-plugin-2.5.0.476.jar -fSL https://sonarsource.bintray.com/Distribution/sonar-web-plugin/sonar-web-plugin-2.5.0.476.jar \
    && curl -o sonar-xml-plugin-1.4.2.885.jar -fSL https://sonarsource.bintray.com/Distribution/sonar-xml-plugin/sonar-xml-plugin-1.4.2.885.jar \
    && curl -o sonar-groovy-plugin-1.5.jar -fSL https://github.com/SonarQubeCommunity/sonar-groovy/releases/download/1.5/sonar-groovy-plugin-1.5.jar

VOLUME "$SONARQUBE_HOME/data"

WORKDIR $SONARQUBE_HOME
COPY run.sh $SONARQUBE_HOME/bin/
COPY sonar.properties $SONARQUBE_HOME/conf

EXPOSE 22

ENTRYPOINT ["./bin/run.sh"]
