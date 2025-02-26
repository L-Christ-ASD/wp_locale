ENV-FILE=.env

include ./.env

sonarqube:
	@ docker compose up sonarqube sonar_db

sonar-scan:
	docker run \
    --rm \
    --network=1wordpress_deployment_sonar_network \
    -e SONAR_HOST_URL="http://172.18.0.3:9000"  \ 
    -e SONAR_TOKEN="${SONAR_TOKEN}" \
    -v "/home/christ/1wordPress_deployment:/usr/src" \
    sonarsource/sonar-scanner-cli \
	-Dsonar.projectKey=${PROJECT_KEY}

	

project:
	@docker compose up 