#!/usr/bin/env bash
set -m
docker/entrypoint.sh &

while [ "$(curl -s http://127.0.0.1:9000 | grep 'data-server-status=\"UP\"')" == "" ]
do
    echo "Waiting on SonarQube to start...";
    sleep 5;
done

wget -O sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.2.1.4610-linux-x64.zip?_gl=1*cjns03*_gcl_au*MjAwNzc0Nzc1NC4xNzI4NDA2NjY5*_ga*NDU3NTU5MzkzLjE3Mjg0MDY2Njk.*_ga_9JZ0GZ5TC6*MTcyODQwNjY2OS4xLjEuMTcyODQxMzA2Ny42MC4wLjA.
unzip sonar-scanner-cli.zip
export SONAR_SCANNER=$(pwd)/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner
echo "export SONAR_SCANNER=$(pwd)/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner" >> /home/sonarqube/.profile

acctname=$(tr -dc a-z0-9 </dev/urandom | head -c 13; echo)
resp=$(curl -s -X POST -u admin:admin http://127.0.0.1:9000/api/user_tokens/generate?name=$acctname)
export SONAR_TOKEN=$(echo $resp | grep -o '"token":"[^"]*' | grep -o '[^"]*$')
echo "export SONAR_TOKEN=$(echo $resp | grep -o '"token":"[^"]*' | grep -o '[^"]*$')" >> /home/sonarqube/.profile

$SONAR_SCANNER -Dsonar.projectBaseDir=/codebase  -Dsonar.host.url=http://127.0.0.1:9000  -Dsonar.token=$SONAR_TOKEN

fg %1
