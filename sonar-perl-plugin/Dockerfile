FROM sonarqube:community

USER root

RUN apt-get update \
    && apt-get install -y zip unzip libperl-critic-perl \
    && mkhomedir_helper sonarqube \
    && chown -R sonarqube:root /opt/sonarqube \
    && chmod u+w /opt/sonarqube \
    && rm -rf /var/cache/apt/archives \
    && rm -rf /var/cache/apt/lists     

COPY --chown=sonarqube:root startup.sh /opt/sonarqube/  

USER sonarqube
RUN wget -q -O /opt/sonarqube/extensions/plugins/sonar-perl-plugin-0.6.1-snapshot-all.jar https://github.com/razac05/sonar-perl/releases/download/0.6.1-snapshot/sonar-perl-plugin-0.6.1-snapshot-all.jar \
    && wget -q -O /opt/sonarqube/extensions/plugins/sonar-cnes-report-5.0.0.jar https://github.com/cnescatlab/sonar-cnes-report/releases/download/5.0.0/sonar-cnes-report-5.0.0.jar \
    && wget -q -O sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.2.1.4610-linux-x64.zip?_gl=1*cjns03*_gcl_au*MjAwNzc0Nzc1NC4xNzI4NDA2NjY5*_ga*NDU3NTU5MzkzLjE3Mjg0MDY2Njk.*_ga_9JZ0GZ5TC6*MTcyODQwNjY2OS4xLjEuMTcyODQxMzA2Ny42MC4wLjA. \
    && unzip sonar-scanner-cli.zip

ENV SONAR_SCANNER="/opt/sonarqube/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner"
ENV SONAR_REPORT="/opt/sonarqube/extensions/plugins/sonar-cnes-report-5.0.0.jar"