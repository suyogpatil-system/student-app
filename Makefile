# Define variables
IMAGE_NAME=suyogpatil/student-app
TAG=v1
DOCKER_IMAGE=student-api
DOCKER_TAG=v1
CODE_DIR=src/
NETWORK_NAME=app-network
DB_CONTAINER=mysql-container
DB_PORT=3306
DB_ROOT_PASSWORD=rootpassword
DB_NAME=studentdb
DB_USER=studentuser
DB_PASSWORD=password

# Install Java (OpenJDK 17)
install-java:
	@echo "Installing Java (OpenJDK 17)..."
	sudo apt-get update
	sudo apt-get install -y openjdk-17-jdk
	java -version
	@echo "Java installation completed!"

install-maven:
	@echo "Installing Maven $(MAVEN_VERSION)..."
	sudo apt-get update
	sudo apt-get install -y wget
	wget https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz
	sudo tar -xvzf apache-maven-3.8.8-bin.tar.gz -C /opt
	sudo rm -rf /usr/bin/mvn
	sudo ln -s /opt/apache-maven-3.8.8/bin/mvn /usr/bin/mvn
	mvn -version
	sudo rm -rf apache-maven-3.8.8-bin.*
	@echo "Maven installation completed!"

# Install Docker (optional for containerization)
install-docker:
	@echo "Installing Docker..."
	@sudo apt-get update
	@sudo apt-get install ca-certificates curl
	@sudo install -m 0755 -d /etc/apt/keyrings
	@sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	@sudo chmod a+r /etc/apt/keyrings/docker.asc
	@echo "deb [arch=$(ARCH) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	@sudo apt-get update
	@sudo apt-get install -y -f  containerd.io docker-ce docker-ce-cli docker-compose docker-buildx-plugin docker-compose-plugin
	@docker --version
	@echo "Docker installation completed!"

install-all: install-java install-maven install-docker

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

docker-build:
	docker build -t $(IMAGE_NAME):$(TAG) .

docker-push:
	#echo $(DOCKERHUB_PASSWORD) | docker login -u $(DOCKERHUB_USERNAME) --password-stdin
	docker push $(IMAGE_NAME):$(TAG)

all: docker-build docker-push

# Start Docker Compose
docker-compose-start:
	@echo "Starting services using Docker Compose..."
	docker-compose up --build
