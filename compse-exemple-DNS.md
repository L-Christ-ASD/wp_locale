
services:
  reverse-proxy:
    image: traefik:3.2
    container_name: traefik
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"  # Ajout pour le challenge TLS
      - "8080:8080" # Tableau de bord de Traefik
    command:
      - --api.dashboard=true # Active l'interface du tableau de bord sans authentification
      - --entrypoints.web.address=:80 # Définit un entrypoint HTTP sur le port 80
      - --entrypoints.websecure.address=:443
      - --certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web
      - --certificatesresolvers.myresolver.acme.email=christ.lumu@oclock.school
      - --certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json
      - --providers.docker.defaultRule=Host(`*.l-christ-asd-server.eddi.cloud`) # utilise le nom du service défini dans docker-compose.yml comme sous-domaine.
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock # Permet à Traefik d'accéder aux informations des conteneurs Docker
      - ./letsencrypt:/letsencrypt
    networks:
    - traefik-network
    

  wordpress:
    container_name: wordpress
    restart: unless-stopped

    build:
      context: ./wordpress
      dockerfile: Dockerfile
    ports:
      - "81:80"
    environment:
      WORDPRESS_DB_HOST: ${WP_DB_HOST}
      WORDPRESS_DB_USER: ${WP_DB_USER}
      WORDPRESS_DB_PASSWORD: ${WP_DB_PASSWORD}
      WORDPRESS_DB_NAME: ${WP_DB_NAME}

    volumes:
      - wordpress_data:/var/www/html

    depends_on:
      db:
        condition: service_healthy

    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.wordpress.rule=Host(`wordpress.l-christ-asd-server.eddi.cloud`)"
      - "traefik.http.routers.wordpress.entrypoints=websecure"
      - "traefik.http.routers.wordpress.tls.certresolver=myresolver"
      - "traefik.http.services.wordpress.loadbalancer.server.port=80"
      - "traefik.http.routers.sonarqube.entrypoints=web"
    networks:
      - wp-network
      - traefik-network

  db:
    image: mysql:8.0
    container_name: mysql
    restart: unless-stopped

    environment:
      MYSQL_DATABASE: ${MYSQL_DB}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_RT_PASSWORD}

    volumes:
      - db_data:/var/lib/mysql

    networks:
      - wp-network
    
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-u", "${MYSQL_USER}", "-p${MYSQL_PASSWORD}", "-h", "localhost"]
      interval: 20s
      timeout: 20s
      retries: 5
      start_period: 30s

  phpmyadmin:
    container_name: phpmyadmin
    restart: unless-stopped

    build:
      context: ./phpmyadmin
      dockerfile: Dockerfile

    ports:
      - "82:80"

    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: ${MYSQL_RT_PASSWORD}

    depends_on:    
      db:
        condition: service_healthy

    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.phpmyadmin.rule=Host(`phpmyadmin.l-christ-asd-server.eddi.cloud`)"
      - "traefik.http.routers.phpmyadmin.entrypoints=websecure"
      - "traefik.http.routers.phpmyadmin.tls.certresolver=myresolver"
      - "traefik.http.services.phpmyadmin.loadbalancer.server.port=80"
      - "traefik.http.routers.sonarqube.entrypoints=web"
    networks:
      - wp-network
      - traefik-network

  sonarqube:
    image: sonarqube:lts
    container_name: sonarqube
    restart: unless-stopped

    environment:
      - SONARQUBE_JDBC_URL=jdbc:postgresql://sonar_db:5432/sonar
      - SONARQUBE_JDBC_USERNAME=sonar
      - SONARQUBE_JDBC_PASSWORD=sonar

    ports:
      - "9000:9000"

    volumes:
      - sonarqube_data:/opt/sonarqube/data
      #- sonarqube_extensions:/opt/sonarqube/extensions --> pas assez
      #- sonarqube_logs:/opt/sonarqube/logs

    depends_on:
      sonar_db:
        condition: service_healthy

    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.sonarqube.entrypoints=web"
      - "traefik.http.routers.sonarqube.rule=Host(`sonarqube.l-christ-asd-server.eddi.cloud`)"
      - "traefik.http.routers.sonarqube.entrypoints=websecure"
      - "traefik.http.routers.sonarqube.tls.certresolver=myresolver"
      - "traefik.http.services.sonarqube.loadbalancer.server.port=9000"
      
    networks:
      - sonar_network
      - traefik-network



  sonar_db:
    image: postgres:alpine
    container_name: sonar_db
    restart: unless-stopped
    env_file:
      - .env
    networks:
      - sonar_network
    volumes:
      - postgres_data:/var/lib/postgresql/data:rw
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "sonar","-h", "localhost"]
      interval: 10s
      timeout: 15s
      retries: 5 
      start_period: 30s
    

volumes:
  postgres_data:
  wordpress_data:
  sonarqube_data:
  db_data:

networks:
  
  traefik-network:
    driver: bridge
  sonar_network:
    driver: bridge
  wp-network:
    driver: bridge