FROM sonarqube:10.6-community

# USER root

# RUN apt-get update && apt-get install -y zip unzip

COPY --chown=sonarqube:root build/libs/*all.jar /opt/sonarqube/extensions/plugins/
# COPY --chown=sonarqube:root --chmod=755 startup.sh /opt/sonarqube/

# RUN chown -R sonarqube:root /opt/sonarqube \
#     && chmod u+w /opt/sonarqube \
#     && mkhomedir_helper sonarqube

# USER sonarqube

# ENTRYPOINT [ "/opt/sonarqube/startup.sh" ]