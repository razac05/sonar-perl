#!/usr/bin/env bash
CODEBASE_ROOT=$@

set -m

# wget -q -O /opt/sonarqube/extensions/plugins/sonar-cnes-report-5.0.0.jar https://github.com/cnescatlab/sonar-cnes-report/releases/download/5.0.0/sonar-cnes-report-5.0.0.jar 

docker/entrypoint.sh &

# Wait for SonarQube to finish initializing
while [ "$(curl -s http://127.0.0.1:9000 | grep 'data-server-status=\"UP\"')" == "" ]
do
    echo "Waiting on SonarQube to start...";
    sleep 5;
done

# Get the Sonar Scanner CLI
# wget -O sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.2.1.4610-linux-x64.zip?_gl=1*cjns03*_gcl_au*MjAwNzc0Nzc1NC4xNzI4NDA2NjY5*_ga*NDU3NTU5MzkzLjE3Mjg0MDY2Njk.*_ga_9JZ0GZ5TC6*MTcyODQwNjY2OS4xLjEuMTcyODQxMzA2Ny42MC4wLjA.
# unzip sonar-scanner-cli.zip
# export SONAR_SCANNER=$(pwd)/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner
# echo "export SONAR_SCANNER=$(pwd)/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner" >> /home/sonarqube/.profile

# Create user token
acctname=$(tr -dc a-z0-9 </dev/urandom | head -c 13; echo)
resp=$(curl -s -X POST -u admin:admin http://127.0.0.1:9000/api/user_tokens/generate?name=$acctname)
export SONAR_TOKEN=$(echo $resp | grep -o '"token":"[^"]*' | grep -o '[^"]*$')
echo "export SONAR_TOKEN=$(echo $resp | grep -o '"token":"[^"]*' | grep -o '[^"]*$')" >> /home/sonarqube/.profile

# Setup SonarQube scan
cd $CODEBASE_ROOT
SONAR_PROJECT_KEY=$(awk '{ print $2 }' FS='sonar.projectKey=' sonar-project.properties | awk '1' RS='')
echo "export SONAR_PROJECT_KEY=$(awk '{ print $2 }' FS='sonar.projectKey=' sonar-project.properties | awk '1' RS='')" >> /home/sonarqube/.profile

PERL_SRC=$(awk '{ print $2 }' FS='sonar.sources=' sonar-project.properties | awk '1' RS='')
echo "export PERL_SRC=$(awk '{ print $2 }' FS='sonar.sources=' sonar-project.properties | awk '1' RS='')" >> /home/sonarqube/.profile

PERL_TEST=$(awk '{ print $2 }' FS='sonar.tests=' sonar-project.properties | awk '1' RS='')
echo "export PERL_TEST=$(awk '{ print $2 }' FS='sonar.tests=' sonar-project.properties | awk '1' RS='')" >> /home/sonarqube/.profile

perlcritic --cruel --quiet --verbose "%f~|~%s~|~%l~|~%c~|~%m~|~%e~|~%p~||~%n" $PERL_SRC $PERL_TEST > perlcritic_report.txt

# Run SonarQube scan
$SONAR_SCANNER -Dsonar.host.url=http://127.0.0.1:9000  -Dsonar.token=$SONAR_TOKEN

# Export SonarQube report data
java -jar $SONAR_REPORT -p $SONAR_PROJECT_KEY -t $SONAR_TOKEN -o $CODEBASE_ROOT/SAST/

#fg %1
