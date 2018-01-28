FROM openjdk:8 

MAINTAINER Allan Selvan <allantony2008@gmail.com>
LABEL authors="Allan Selvan <allantony2008@gmail.com>"
LABEL version="6.7.1"
LABEL description="Docker container for Sonarqube"

ADD VERSION .

ENV SONAR_VERSION='6.7.1' \
    SONARQUBE_HOME='/appl/sonarqube' \
    SONARQUBE_JDBC_USERNAME='sonarqube' \
    SONARQUBE_LDAP_PLUGIN_VERSION='2.2.0.608' \
    SONARQUBE_JAVA_PLUGIN_VERSION='5.0.1.12818' \
    SONARQUBE_JS_PLUGIN_VERSION='4.0.0.5862' \
    SONARQUBE_GIT_PLUGIN_VERSION='1.3.0.869' \
    SONARQUBE_WEB_PLUGIN_VERSION='2.5.0.476' \
    SONARQUBE_XML_PLUGIN_VERSION='1.4.3.1027' \
    SONARQUBE_GROOVY_PLUGIN_VERSION='1.4' \
    SONARQUBE_GOLANG_PLUGIN_VERSION='1.2.11-rc9'

# Http port
EXPOSE 9000

RUN mkdir /appl

RUN groupadd -r sonarqube && useradd -r -g sonarqube sonarqube

# grab gosu for easy step-down from root
RUN set -x \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN set -x \
    && cd /appl \
    && curl -o sonarqube.zip -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip \
    && unzip -q sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sonarqube \
    && chown -R sonarqube:sonarqube sonarqube \
    && rm sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/*

RUN cd $SONARQUBE_HOME/extensions/plugins \
    && curl -o sonar-ldap-plugin-$SONARQUBE_LDAP_PLUGIN_VERSION.jar -fSL https://sonarsource.bintray.com/Distribution/sonar-ldap-plugin/sonar-ldap-plugin-$SONARQUBE_LDAP_PLUGIN_VERSION.jar \
    && curl -o sonar-java-plugin-$SONARQUBE_JAVA_PLUGIN_VERSION.jar -fSL https://sonarsource.bintray.com/Distribution/sonar-java-plugin/sonar-java-plugin-$SONARQUBE_JAVA_PLUGIN_VERSION.jar \
    && curl -o sonar-javascript-plugin-$SONARQUBE_JS_PLUGIN_VERSION.jar -fSL https://sonarsource.bintray.com/Distribution/sonar-javascript-plugin/sonar-javascript-plugin-$SONARQUBE_JS_PLUGIN_VERSION.jar \
    && curl -o sonar-scm-git-plugin-$SONARQUBE_GIT_PLUGIN_VERSION.jar -fSL https://sonarsource.bintray.com/Distribution/sonar-scm-git-plugin/sonar-scm-git-plugin-$SONARQUBE_GIT_PLUGIN_VERSION.jar \
    && curl -o sonar-web-plugin-$SONARQUBE_WEB_PLUGIN_VERSION.jar -fSL https://sonarsource.bintray.com/Distribution/sonar-web-plugin/sonar-web-plugin-$SONARQUBE_WEB_PLUGIN_VERSION.jar \
    && curl -o sonar-xml-plugin-$SONARQUBE_XML_PLUGIN_VERSION.jar -fSL https://sonarsource.bintray.com/Distribution/sonar-xml-plugin/sonar-xml-plugin-$SONARQUBE_XML_PLUGIN_VERSION.jar \
    && curl -o sonar-groovy-plugin-$SONARQUBE_GROOVY_PLUGIN_VERSION.jar -fSL https://sonarsource.bintray.com/Distribution/sonar-groovy-plugin/sonar-groovy-plugin-$SONARQUBE_GROOVY_PLUGIN_VERSION.jar \
    && curl -o sonar-golang-plugin-$SONARQUBE_GOLANG_PLUGIN_VERSION.jar -fSL https://github.com/uartois/sonar-golang/releases/download/v$SONARQUBE_GOLANG_PLUGIN_VERSION/sonar-golang-plugin-$SONARQUBE_GOLANG_PLUGIN_VERSION.jar

VOLUME "$SONARQUBE_HOME/data"

WORKDIR $SONARQUBE_HOME
COPY run.sh $SONARQUBE_HOME/bin/
COPY sonar.properties $SONARQUBE_HOME/conf

EXPOSE 22

# Add Tini
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "-v", "-g", "--", "./bin/run.sh"]