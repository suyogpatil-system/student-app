# Define variables
DOCKER_IMAGE=student-api
DOCKER_TAG=v1
DOCKER_REGISTRY=suyogpatil/student-app
CODE_DIR=src/
NETWORK_NAME=app-network
DB_CONTAINER=mysql-container
DB_PORT=3306
DB_ROOT_PASSWORD=rootpassword
DB_NAME=studentdb
DB_USER=studentuser
DB_PASSWORD=password

# Run Spring Boot application locally
run:
	@echo "Running Spring Boot application locally..."
	mvn spring-boot:run

# Build API
build:
	@echo "Building the API..."
	mvn clean package -DskipTests

# Run tests
test:
	@echo "Running tests..."
	mvn test

# Perform linting
lint:
	@echo "Performing linting..."
	mvn checkstyle:check

# Build Docker image for the Spring Boot application
docker-app-build:
	@echo "Building Docker image for the Spring Boot application..."
	docker build -t ${DOCKER_IMAGE} .

# Create Docker private network (if not exists)
docker-network-create:
	@echo "Creating Docker private network..."
	@if ! docker network ls | grep -q ${NETWORK_NAME}; then \
		docker network create ${NETWORK_NAME}; \
	else \
		echo "Network '${NETWORK_NAME}' already exists."; \
	fi

# Run MySQL Docker container
docker-db-run:
	@echo "Running MySQL Docker container..."
	@if ! docker ps | grep -q ${DB_CONTAINER}; then \
		docker run --net=${NETWORK_NAME} -d --name ${DB_CONTAINER} \
		-e MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD} \
		-e MYSQL_DATABASE=${DB_NAME} \
		-e MYSQL_USER=${DB_USER} \
		-e MYSQL_PASSWORD=${DB_PASSWORD} \
		-p ${DB_PORT}:${DB_PORT} \
		mysql:latest; \
	else \
		echo "Database container '${DB_CONTAINER}' is already running."; \
	fi

# Run Spring Boot application in Docker
docker-app-run: docker-network-create docker-db-run
	@echo "Running Spring Boot application in Docker..."
	docker run --net=${NETWORK_NAME} -it -P \
	-e DB_URL=jdbc:mysql://${DB_CONTAINER}:${DB_PORT}/${DB_NAME} \
	-e DB_USERNAME=${DB_USER} \
	-e DB_PASSWORD=${DB_PASSWORD} \
	${DOCKER_IMAGE}

# Docker login
docker-login:
	@echo "Logging into Docker registry..."
	echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin

# Docker build and push
docker-build-push: docker-login
	@echo "Building Docker image..."
	docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
	@echo "Pushing Docker image..."
	docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}

# Combined target for CI pipeline
ci: build test lint docker-build-push
	@echo "CI pipeline completed."

# Start Docker Compose
docker-compose-start:
	@echo "Starting services using Docker Compose..."
	docker-compose up --build
