FROM sonarqube:community

USER root

RUN apt-get update \
    && apt-get install -y zip unzip libperl-critic-perl \
    && mkhomedir_helper sonarqube \
    && chown -R sonarqube:root /opt/sonarqube \
    && chmod u+w /opt/sonarqube \
    && rm -rf /var/cache/apt/archives \
    && rm -rf /var/cache/apt/lists     

COPY --chown=sonarqube:root build/libs/*all.jar /opt/sonarqube/extensions/plugins/
COPY --chown=sonarqube:root startup.sh /opt/sonarqube/  
COPY --chown=sonarqube:root build/sample-project /codebase/

USER sonarqube

# ENTRYPOINT [ "/opt/sonarqube/startup.sh" ]